import 'package:get_it/get_it.dart';

import '../data/data_source/invest_remote_data_source.dart';
import '../data/repositories/invest_repository_impl.dart';
import '../domain/repositories/invest_repository.dart';
import '../presentation/cubit/invest_cubit.dart';

final getIt = GetIt.instance;

void initInvestModule() {
  // Data source
  getIt.registerLazySingleton<InvestRemoteDataSource>(
    () => InvestRemoteDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<InvestRepository>(
    () => InvestRepositoryImpl(getIt()),
  );

  // Cubit
  getIt.registerFactory(
    () => InvestCubit(getIt()),
  );
}
