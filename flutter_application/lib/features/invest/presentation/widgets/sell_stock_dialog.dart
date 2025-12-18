import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application/core/constants/app_colors.dart';
import '../../domain/entities/portfolio_item.dart';

class SellStock extends StatelessWidget {
  final PortfolioItem item;
  final TextEditingController _quantityController = TextEditingController();

  SellStock({super.key, required this.item}) {
    _quantityController.text = item.totalUnits.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final hargaJual = item.currentValue / item.totalUnits;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jual ${item.code}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.b93160,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Jumlah dimiliki: ${item.totalUnits.toStringAsFixed(0)} unit',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 8),

            Text(
              'Harga jual: Rp ${hargaJual.toStringAsFixed(0)} / unit',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah unit',
                suffixIcon: TextButton(
                  onPressed: () {
                    _quantityController.text =
                        item.totalUnits.toStringAsFixed(0);
                  },
                  child: const Text('MAX'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                final qty = double.tryParse(_quantityController.text) ?? 0;

                if (qty <= 0 || qty > item.totalUnits) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jumlah tidak valid'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                _sell(context, qty);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.b93160,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Jual Sekarang'),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }

  /// ================================
  /// SELL LOGIC (LIFO – REALISTIC)
  /// ================================
  Future<void> _sell(BuildContext context, double sellQty) async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      /// 1️⃣ GET ACTIVE PORTFOLIO
      final portfolio = await supabase
          .from('virtual_portfolios')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .single();

      final portfolioId = portfolio['id'];
      final sellPrice = item.currentValue / item.totalUnits;
      double remainingQty = sellQty;

      /// 2️⃣ GET STOCK LOTS (LIFO)
      final stocks = await supabase
          .from('virtual_stocks')
          .select()
          .eq('portfolio_id', portfolioId)
          .eq('asset_symbol', item.code)
          .order('created_at', ascending: false);

      if (stocks.isEmpty) {
        throw Exception('No stock available');
      }

      double totalCost = 0;

      /// 3️⃣ REDUCE STOCK LOTS
      for (final row in stocks) {
        if (remainingQty <= 0) break;

        final rowQty = (row['quantity'] as num).toDouble();
        final buyPrice = (row['bought_price'] as num).toDouble();

        if (rowQty <= 0) continue;

        if (rowQty >= remainingQty) {
          totalCost += remainingQty * buyPrice;

          await supabase
              .from('virtual_stocks')
              .update({'quantity': rowQty - remainingQty})
              .eq('id', row['id']);

          remainingQty = 0;
        } else {
          totalCost += rowQty * buyPrice;

          await supabase
              .from('virtual_stocks')
              .update({'quantity': 0})
              .eq('id', row['id']);

          remainingQty -= rowQty;
        }
      }

      if (remainingQty > 0) {
        throw Exception('Insufficient quantity');
      }

      /// 4️⃣ INSERT TRANSACTION
      final totalSell = sellQty * sellPrice;
      final profitLoss = totalSell - totalCost;

      await supabase.from('virtual_transactions').insert({
        'portfolio_id': portfolioId,
        'type': 'sell',
        'asset_symbol': item.code,
        'asset_type': 'stock',
        'quantity': sellQty,
        'price': sellPrice,
        'total_amount': totalSell,
        'created_at': DateTime.now().toIso8601String(),
      });

      /// 5️⃣ UPDATE PORTFOLIO BALANCE
      await supabase.from('virtual_portfolios').update({
        'current_balance':
            (portfolio['current_balance'] as num).toDouble() + totalSell,
      }).eq('id', portfolioId);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menjual saham'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menjual: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
