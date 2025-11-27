part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final CashflowSummary? cashflowSummary;
  final List<Transaction> recentTransactions;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.cashflowSummary,
    this.recentTransactions = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    CashflowSummary? cashflowSummary,
    List<Transaction>? recentTransactions,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      cashflowSummary: cashflowSummary ?? this.cashflowSummary,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cashflowSummary,
        recentTransactions,
        errorMessage,
      ];
}
