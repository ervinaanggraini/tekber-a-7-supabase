import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/entities/cashflow_summary.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getRecentTransactions({int limit = 10});
  Future<CashflowSummary> getCashflowSummary({DateTime? month});
  Future<Transaction> createTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<List<Category>> getCategories({String? type});
}
