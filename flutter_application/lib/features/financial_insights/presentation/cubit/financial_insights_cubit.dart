import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/financial_insights/domain/use_cases/get_financial_insights_use_case.dart';
import 'package:flutter_application/features/financial_insights/presentation/cubit/financial_insights_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class FinancialInsightsCubit extends Cubit<FinancialInsightsState> {
  final GetFinancialInsightsUseCase getFinancialInsightsUseCase;

  FinancialInsightsCubit(this.getFinancialInsightsUseCase) : super(FinancialInsightsInitial());

  Future<void> loadInsights(String userId) async {
    emit(FinancialInsightsLoading());
    final result = await getFinancialInsightsUseCase(userId);
    result.fold(
      (failure) => emit(FinancialInsightsError(failure.message)),
      (insights) => emit(FinancialInsightsLoaded(insights)),
    );
  }
}
