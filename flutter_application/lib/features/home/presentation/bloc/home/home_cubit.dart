import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/features/transactions/domain/entities/cashflow_summary.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/domain/use_cases/get_cashflow_summary_use_case.dart';
import 'package:flutter_application/features/transactions/domain/use_cases/get_recent_transactions_use_case.dart';

part 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final GetCashflowSummaryUseCase getCashflowSummaryUseCase;
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;

  HomeCubit({
    required this.getCashflowSummaryUseCase,
    required this.getRecentTransactionsUseCase,
  }) : super(HomeState());

  Future<void> loadHomeData() async {
    emit(state.copyWith(status: HomeStatus.loading));

    try {
      // Load cashflow summary and recent transactions in parallel
      final results = await Future.wait([
        getCashflowSummaryUseCase.execute(const GetCashflowSummaryParams()),
        getRecentTransactionsUseCase.execute(10),
      ]);

      final cashflowSummary = results[0] as CashflowSummary;
      final transactions = results[1] as List<Transaction>;

      emit(state.copyWith(
        status: HomeStatus.loaded,
        cashflowSummary: cashflowSummary,
        recentTransactions: transactions,
      ));
    } catch (e) {
      debugPrint('Error loading home data: $e');
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refreshHomeData() async {
    await loadHomeData();
  }

  Future<void> changeMonth(DateTime newMonth) async {
    emit(state.copyWith(
      selectedMonth: newMonth,
      status: HomeStatus.loading,
    ));

    try {
      final cashflowSummary = await getCashflowSummaryUseCase.execute(
        GetCashflowSummaryParams(month: newMonth),
      );

      emit(state.copyWith(
        status: HomeStatus.loaded,
        cashflowSummary: cashflowSummary,
      ));
    } catch (e) {
      debugPrint('Error changing month: $e');
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
