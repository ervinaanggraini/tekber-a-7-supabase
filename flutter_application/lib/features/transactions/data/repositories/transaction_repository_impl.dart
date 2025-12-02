import 'package:injectable/injectable.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/entities/cashflow_summary.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter_application/features/transactions/data/data_sources/transaction_remote_data_source.dart';
import 'package:flutter_application/features/transactions/data/models/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    return await remoteDataSource.getRecentTransactions(limit: limit);
  }

  @override
  Future<CashflowSummary> getCashflowSummary({DateTime? month}) async {
    final data = await remoteDataSource.getCashflowData(month: month);
    
    final totalIncome = data['totalIncome'] ?? 0;
    final totalExpense = data['totalExpense'] ?? 0;
    final balance = data['balance'] ?? 0;
    
    final total = totalIncome + totalExpense;
    final incomePercentage = total > 0 ? (totalIncome / total) * 100 : 0.0;
    final expensePercentage = total > 0 ? (totalExpense / total) * 100 : 0.0;

    return CashflowSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      incomePercentage: incomePercentage,
      expensePercentage: expensePercentage,
    );
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      category: transaction.category,
      type: transaction.type,
      amount: transaction.amount,
      description: transaction.description,
      notes: transaction.notes,
      transactionDate: transaction.transactionDate,
      transactionTime: transaction.transactionTime,
      inputMethod: transaction.inputMethod,
      receiptImageUrl: transaction.receiptImageUrl,
      merchantName: transaction.merchantName,
      createdAt: transaction.createdAt,
    );
    
    return await remoteDataSource.createTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    return await remoteDataSource.deleteTransaction(transactionId);
  }

  @override
  Future<List<Category>> getCategories({String? type}) async {
    return await remoteDataSource.getCategories(type: type);
  }
}
