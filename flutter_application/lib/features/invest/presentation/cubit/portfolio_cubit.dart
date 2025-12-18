import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'portfolio_state.dart';
import '../../domain/entities/portfolio_item.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit() : super(PortfolioLoading());

  Future<void> loadPortfolio() async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // 1️⃣ Ambil portfolio aktif
      final portfolio = await supabase
          .from('virtual_portfolios')
          .select('id, current_balance')
          .eq('user_id', user.id)
          .eq('is_active', true)
          .single();

      final portfolioId = portfolio['id'];
      final double totalValue =
          (portfolio['current_balance'] as num).toDouble();

      // 2️⃣ Ambil semua saham di portfolio
      final stocks = await supabase
          .from('virtual_stocks')
          .select()
          .eq('portfolio_id', portfolioId);

      // 3️⃣ Group by asset_symbol
      final Map<String, PortfolioItem> grouped = {};

      for (final row in stocks) {
        final String symbol = row['asset_symbol'];
        final double quantity = (row['quantity'] as num).toDouble();
        final double boughtPrice = (row['bought_price'] as num).toDouble();

        if (!grouped.containsKey(symbol)) {
          grouped[symbol] = PortfolioItem(
            code: symbol,
            name: _resolveName(symbol),
            totalUnits: 0,
            totalInvested: 0,
            currentValue: 0,
          );
        }

        final item = grouped[symbol]!;

        item.totalUnits += quantity;
        item.totalInvested += quantity * boughtPrice;

        // sementara: anggap current price = bought_price terakhir
        item.currentValue = item.totalUnits * boughtPrice;
      }

      emit(
        PortfolioLoaded(
          totalValue: totalValue,
          totalPercentage: 0, // nanti bisa dihitung
          items: grouped.values.toList(),
        ),
      );
    } catch (e) {
      emit(PortfolioError(e.toString()));
    }
  }

  /// helper biar rapi
  String _resolveName(String symbol) {
    switch (symbol) {
      case 'BBCA':
        return 'Bank Central Asia';
      case 'GOTO':
        return 'GoTo Gojek Tokopedia';
      default:
        return symbol;
    }
  }
}
