import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/report_summary.dart';
import '../repositories/report_repository.dart';

class GetReportSummaryParams extends Equatable {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const GetReportSummaryParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

@injectable
class GetReportSummaryUseCase {
  final ReportRepository repository;

  GetReportSummaryUseCase(this.repository);

  Future<ReportSummary> execute(GetReportSummaryParams params) {
    return repository.getReportSummary(
      params.userId,
      params.startDate,
      params.endDate,
    );
  }
}
