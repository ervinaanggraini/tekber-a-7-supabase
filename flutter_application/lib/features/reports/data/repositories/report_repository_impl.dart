import 'package:injectable/injectable.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/repositories/report_repository.dart';
import '../data_sources/report_remote_data_source.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<ReportSummary> getReportSummary(String userId, DateTime startDate, DateTime endDate) {
    return remoteDataSource.getReportSummary(userId, startDate, endDate);
  }
}
