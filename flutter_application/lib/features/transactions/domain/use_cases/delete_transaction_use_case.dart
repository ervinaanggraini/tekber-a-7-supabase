import 'package:flutter_application/core/use_cases/async_use_case.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteTransactionUseCase implements AsyncUseCase<void, String> {
  final TransactionRepository _repository;

  DeleteTransactionUseCase(this._repository);

  @override
  Future<void> execute(String transactionId) {
    return _repository.deleteTransaction(transactionId);
  }
}
