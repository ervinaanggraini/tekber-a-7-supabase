import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/spacings.dart';
import '../../../../dependency_injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../utils/transaction_export_generator.dart';
import '../utils/transaction_pdf_generator.dart';
import '../../../reports/presentation/utils/export_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../bloc/transaction_bloc.dart';
import 'add_transaction_page.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransactionBloc>(),
      child: const _TransactionHistoryView(),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView();

  @override
  State<_TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  String _selectedFilter = 'all'; // all, income, expense

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthUserAuthenticated) {
      context.read<TransactionBloc>().add(
            LoadTransactionsEvent(userId: authState.user.id),
          );
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (_selectedFilter == 'income') {
      return transactions.where((t) => t.type == 'income').toList();
    } else if (_selectedFilter == 'expense') {
      return transactions.where((t) => t.type == 'expense').toList();
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.pink[200] : AppColors.b93160,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.pink[200] : AppColors.b93160),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            margin: const EdgeInsets.all(Spacing.s16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isDark ? Border.all(color: Colors.grey[700]!, width: 1) : null,
            ),
            child: Row(
              children: [
                _buildFilterTab('Semua', 'all', isDark),
                _buildFilterTab('Pemasukan', 'income', isDark),
                _buildFilterTab('Pengeluaran', 'expense', isDark),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTransactions,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TransactionLoaded) {
                  final filteredTransactions = _filterTransactions(state.transactions);

                  if (filteredTransactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Belum ada transaksi',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Group by date
                  final groupedTransactions = <String, List<Transaction>>{};
                  for (var transaction in filteredTransactions) {
                    final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
                    groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
                  }

                  final sortedDates = groupedTransactions.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.s16, vertical: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Choose period first
                              final period = await showModalBottomSheet<String?>(
                                context: context,
                                builder: (ctx) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(leading: const Icon(Icons.calendar_view_week), title: const Text('Mingguan'), onTap: () => Navigator.of(ctx).pop('week')),
                                      ListTile(leading: const Icon(Icons.calendar_view_month), title: const Text('Bulanan'), onTap: () => Navigator.of(ctx).pop('month')),
                                      ListTile(leading: const Icon(Icons.calendar_today), title: const Text('Tahunan'), onTap: () => Navigator.of(ctx).pop('year')),
                                      ListTile(leading: const Icon(Icons.close), title: const Text('Batal'), onTap: () => Navigator.of(ctx).pop(null)),
                                    ],
                                  ),
                                ),
                              );

                              if (period == null) return; // cancelled

                              if (!mounted) return;

                              // Now choose pdf or excel
                              final choice = await showModalBottomSheet<String?>(
                                context: context,
                                builder: (ctx) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(leading: const Icon(Icons.picture_as_pdf), title: const Text('PDF'), onTap: () => Navigator.of(ctx).pop('pdf')),
                                      ListTile(leading: const Icon(Icons.table_chart), title: const Text('Excel'), onTap: () => Navigator.of(ctx).pop('excel')),
                                      ListTile(leading: const Icon(Icons.close), title: const Text('Batal'), onTap: () => Navigator.of(ctx).pop(null)),
                                    ],
                                  ),
                                ),
                              );

                              if (choice == null) return;

                              if (!mounted) return;

                              // Compute date range
                              final now = DateTime.now();
                              late DateTime startDate;
                              late DateTime endDate;
                              String periodLabel = '';
                              endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
                              if (period == 'week') {
                                startDate = now.subtract(const Duration(days: 7));
                                periodLabel = 'Minggu_terakhir';
                              } else if (period == 'month') {
                                startDate = DateTime(now.year, now.month, 1);
                                periodLabel = DateFormat('MMMM_yyyy', 'id_ID').format(now);
                              } else if (period == 'year') {
                                startDate = DateTime(now.year, 1, 1);
                                periodLabel = 'Tahun_${now.year}';
                              }

                              // Filter transactions by range
                              final selection = state.transactions.where((tx) =>
                                !tx.date.isBefore(startDate) && !tx.date.isAfter(endDate)
                              ).toList();

                              try {
                                if (choice == 'pdf') {
                                  await TransactionPdfGenerator.generateAndSharePdf(selection, startDate, endDate, periodLabel);
                                  await showExportSuccessDialog(context, 'PDF');
                                } else if (choice == 'excel') {
                                  await TransactionExportGenerator.generateAndShareExcel(selection, startDate, endDate, periodLabel);
                                  await showExportSuccessDialog(context, 'Excel');
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengunduh file: $e')));
                              }
                            },
                            icon: const Icon(Icons.file_upload, color: Colors.white),
                            label: Text('Export Riwayat', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.b93160, padding: const EdgeInsets.symmetric(vertical: 12)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => _loadTransactions(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(Spacing.s16),
                            itemCount: sortedDates.length,
                            itemBuilder: (context, index) {
                              final dateKey = sortedDates[index];
                              final transactions = groupedTransactions[dateKey]!;
                              final date = DateTime.parse(dateKey);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(_formatDateHeader(date), style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.b93160)),
                                  ),
                                  ...transactions.map((transaction) => _buildTransactionCard(transaction, isDark)).toList(),
                                  SizedBox(height: 8.h),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.b93160 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, bool isDark) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Hapus Transaksi?', style: GoogleFonts.poppins()),
              content: Text(
                'Apakah Anda yakin ingin menghapus transaksi ini?',
                style: GoogleFonts.poppins(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Batal', style: GoogleFonts.poppins()),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    'Hapus',
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        context.read<TransactionBloc>().add(
              DeleteTransactionEvent(transactionId: transaction.id),
            );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text(
            transaction.description,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            '${transaction.categoryName} • ${DateFormat('HH:mm').format(transaction.date)}${transaction.itemsCount != null && transaction.itemsCount! > 0 ? ' • ${transaction.itemsCount} item' : ''}',
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (transaction.itemsCount != null && transaction.itemsCount! > 0) ...[
                IconButton(
                  onPressed: () => _showTransactionItems(transaction.id),
                  icon: Icon(Icons.list_alt, size: 20.sp, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  tooltip: 'Lihat item struk',
                ),
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(transaction.amount),
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionPage(
                        transaction: transaction,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTransactionItems(String transactionId) async {
    try {
      final repo = getIt<TransactionRepository>();
      final tx = await repo.getTransactionById(transactionId);
      final items = tx.items ?? [];

      if (items.isEmpty) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Item struk'),
            content: Text('Tidak ada item yang tercatat.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))],
          ),
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Item struk'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final it = items[index];
                return ListTile(
                  title: Text(it.name),
                  subtitle: Text('x${it.quantity} • ${_formatCurrency(it.price)}'),
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: items.length,
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Tutup'))],
        ),
      );
    } catch (e) {
      print('Failed to fetch transaction items: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengambil item struk')));
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return 'Hari Ini';
    } else if (targetDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
  }

  String _formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$formatted';
  }
}
