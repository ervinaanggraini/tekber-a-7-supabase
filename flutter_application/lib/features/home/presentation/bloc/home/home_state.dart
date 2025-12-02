part of 'home_cubit.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final CashflowSummary? cashflowSummary;
  final List<Transaction> recentTransactions;
  final String? errorMessage;
  final DateTime selectedMonth;

  HomeState({
    this.status = HomeStatus.initial,
    this.cashflowSummary,
    this.recentTransactions = const [],
    this.errorMessage,
    DateTime? selectedMonth,
  }) : selectedMonth = selectedMonth ?? DateTime.now();

  HomeState copyWith({
    HomeStatus? status,
    CashflowSummary? cashflowSummary,
    List<Transaction>? recentTransactions,
    String? errorMessage,
    DateTime? selectedMonth,
  }) {
    return HomeState(
      status: status ?? this.status,
      cashflowSummary: cashflowSummary ?? this.cashflowSummary,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      errorMessage: errorMessage,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [
        status,
        cashflowSummary,
        recentTransactions,
        errorMessage,
        selectedMonth,
      ];
}
