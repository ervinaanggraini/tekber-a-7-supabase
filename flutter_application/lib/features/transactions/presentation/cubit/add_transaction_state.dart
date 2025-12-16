part of 'add_transaction_cubit.dart';

abstract class AddTransactionState extends Equatable {
  const AddTransactionState();

  @override
  List<Object?> get props => [];
}

class AddTransactionInitial extends AddTransactionState {
  const AddTransactionInitial();
}

class AddTransactionLoading extends AddTransactionState {
  const AddTransactionLoading();
}

class AddTransactionCategoriesLoaded extends AddTransactionState {
  final List<Category> categories;

  const AddTransactionCategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class AddTransactionCreating extends AddTransactionState {
  const AddTransactionCreating();
}

class AddTransactionCreated extends AddTransactionState {
  final Transaction transaction;

  const AddTransactionCreated({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

class AddTransactionError extends AddTransactionState {
  final String message;

  const AddTransactionError({required this.message});

  @override
  List<Object?> get props => [message];
}
