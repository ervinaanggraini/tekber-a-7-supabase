import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/use_cases/get_report_summary_use_case.dart';

part 'reports_state.dart';

enum ReportPeriod { week, month, year }

@injectable
class ReportsCubit extends Cubit<ReportsState> {
  final GetReportSummaryUseCase getReportSummaryUseCase;

  ReportsCubit(this.getReportSummaryUseCase) : super(ReportsInitial());

  Future<void> loadReport(String userId, ReportPeriod period) async {
    emit(ReportsLoading());

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (period) {
        case ReportPeriod.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case ReportPeriod.month:
          startDate = DateTime(now.year, now.month, 1);
          break;
        case ReportPeriod.year:
          startDate = DateTime(now.year, 1, 1);
          break;
      }

      final summary = await getReportSummaryUseCase.execute(
        GetReportSummaryParams(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        ),
      );

      emit(ReportsLoaded(summary: summary, selectedPeriod: period));
    } catch (e) {
      emit(ReportsError(message: e.toString()));
    }
  }
}
