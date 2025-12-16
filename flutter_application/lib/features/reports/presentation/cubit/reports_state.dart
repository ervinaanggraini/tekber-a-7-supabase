part of 'reports_cubit.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final ReportSummary summary;
  final ReportPeriod selectedPeriod;

  const ReportsLoaded({
    required this.summary,
    required this.selectedPeriod,
  });

  @override
  List<Object?> get props => [summary, selectedPeriod];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}
