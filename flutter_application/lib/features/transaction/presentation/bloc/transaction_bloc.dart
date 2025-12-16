import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../transactions/domain/use_cases/get_recent_transactions_use_case.dart';
import '../../../transactions/domain/use_cases/delete_transaction_use_case.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;
  final DeleteTransactionUseCase _deleteTransactionUseCase;

  TransactionBloc(
    this._getRecentTransactionsUseCase,
    this._deleteTransactionUseCase,
  ) : super(TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getRecentTransactionsUseCase.execute(1000);
      
      // Convert to simpler Transaction model for UI
      final simpleTransactions = transactions.map((t) {
        return Transaction(
          id: t.id,
          userId: t.userId,
          categoryId: t.category.id,
          categoryName: t.category.name,
          type: t.type,
          amount: t.amount,
          description: t.description ?? '',
          date: t.transactionDate,
          createdAt: t.createdAt,
        );
      }).toList();
      
      emit(TransactionLoaded(transactions: simpleTransactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _deleteTransactionUseCase.execute(event.transactionId);
      // Reload transactions after delete
      if (state is TransactionLoaded) {
        final currentState = state as TransactionLoaded;
        final updatedTransactions = currentState.transactions
            .where((t) => t.id != event.transactionId)
            .toList();
        emit(TransactionLoaded(transactions: updatedTransactions));
      }
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }
}
