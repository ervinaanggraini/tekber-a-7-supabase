import 'package:flutter_application/core/use_cases/use_case.dart';
import '../repositories/transaction_repository.dart';
import '../entities/transaction.dart';

class GetTransactionByIdUseCase extends UseCase<Future<Transaction>, String> {
  final TransactionRepository repository;

  GetTransactionByIdUseCase(this.repository);

  @override
  Future<Transaction> execute(String params) async {
    return await repository.getTransactionById(params);
  }
}
