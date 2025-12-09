import '../entities/report_summary.dart';

abstract class ReportRepository {
  Future<ReportSummary> getReportSummary(String userId, DateTime startDate, DateTime endDate);
}
