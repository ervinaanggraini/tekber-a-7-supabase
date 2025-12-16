import 'package:equatable/equatable.dart';
import 'package:flutter_application/core/use_cases/async_use_case.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetCategoriesUseCase implements AsyncUseCase<List<Category>, GetCategoriesParams> {
  final TransactionRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<List<Category>> execute(GetCategoriesParams params) {
    return _repository.getCategories(type: params.type);
  }
}

class GetCategoriesParams extends Equatable {
  final String? type;

  const GetCategoriesParams({
    this.type,
  });

  @override
  List<Object?> get props => [type];
}
