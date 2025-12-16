import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/use_cases/create_transaction_use_case.dart';
import 'package:flutter_application/features/transactions/domain/use_cases/get_categories_use_case.dart';
import 'package:injectable/injectable.dart';

part 'add_transaction_state.dart';

@injectable
class AddTransactionCubit extends Cubit<AddTransactionState> {
  final CreateTransactionUseCase _createTransactionUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  AddTransactionCubit(
    this._createTransactionUseCase,
    this._getCategoriesUseCase,
  ) : super(const AddTransactionInitial());

  Future<void> loadCategories({String? type}) async {
    emit(const AddTransactionLoading());
    try {
      final categories = await _getCategoriesUseCase.execute(
        GetCategoriesParams(type: type),
      );
      emit(AddTransactionCategoriesLoaded(categories: categories));
    } catch (e) {
      emit(AddTransactionError(message: e.toString()));
    }
  }

  Future<void> createTransaction({
    required String userId,
    required Category category,
    required String type,
    required double amount,
    required String description,
    String? notes,
    required DateTime transactionDate,
  }) async {
    emit(const AddTransactionCreating());
    try {
      final transaction = await _createTransactionUseCase.execute(
        CreateTransactionParams(
          userId: userId,
          category: category,
          type: type,
          amount: amount,
          description: description,
          notes: notes,
          transactionDate: transactionDate,
        ),
      );
      emit(AddTransactionCreated(transaction: transaction));
    } catch (e) {
      emit(AddTransactionError(message: e.toString()));
    }
  }
}
