import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_application/core/use_cases/use_case.dart';
import 'package:flutter_application/features/transactions/domain/entities/cashflow_summary.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';

@injectable
class GetCashflowSummaryUseCase extends UseCase<Future<CashflowSummary>, GetCashflowSummaryParams> {
  final TransactionRepository repository;

  GetCashflowSummaryUseCase({required this.repository});

  @override
  Future<CashflowSummary> execute(GetCashflowSummaryParams params) async {
    return await repository.getCashflowSummary();
  }
}

class GetCashflowSummaryParams extends Equatable {
  const GetCashflowSummaryParams();

  @override
  List<Object?> get props => [];
}
