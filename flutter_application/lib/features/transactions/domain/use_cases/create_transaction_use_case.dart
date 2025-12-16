import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/use_cases/async_use_case.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateTransactionUseCase implements AsyncUseCase<Transaction, CreateTransactionParams> {
  final TransactionRepository _repository;

  CreateTransactionUseCase(this._repository);

  @override
  Future<Transaction> execute(CreateTransactionParams params) {
    final transaction = Transaction(
      id: '',
      userId: params.userId,
      category: params.category,
      type: params.type,
      amount: params.amount,
      description: params.description,
      notes: params.notes,
      transactionDate: params.transactionDate,
      inputMethod: 'manual',
      createdAt: DateTime.now(),
    );
    return _repository.createTransaction(transaction);
  }
}

class CreateTransactionParams extends Equatable {
  final String userId;
  final Category category;
  final String type;
  final double amount;
  final String description;
  final String? notes;
  final DateTime transactionDate;

  const CreateTransactionParams({
    required this.userId,
    required this.category,
    required this.type,
    required this.amount,
    required this.description,
    this.notes,
    required this.transactionDate,
  });

  @override
  List<Object?> get props => [
        userId,
        category,
        type,
        amount,
        description,
        notes,
        transactionDate,
      ];
}
