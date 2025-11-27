import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/entities/cashflow_summary.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getRecentTransactions({int limit = 10});
  Future<CashflowSummary> getCashflowSummary();
  Future<Transaction> createTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
}
