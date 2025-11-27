import 'package:injectable/injectable.dart';
import 'package:flutter_application/core/use_cases/use_case.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';

@injectable
class GetRecentTransactionsUseCase extends UseCase<Future<List<Transaction>>, int> {
  final TransactionRepository repository;

  GetRecentTransactionsUseCase({required this.repository});

  @override
  Future<List<Transaction>> execute(int limit) async {
    return await repository.getRecentTransactions(limit: limit);
  }
}
