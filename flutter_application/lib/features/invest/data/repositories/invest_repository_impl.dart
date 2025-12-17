import '../../domain/entities/stock.dart';
import '../../domain/repositories/invest_repository.dart';
import '../data_source/invest_remote_data_source.dart';
import '../models/stock_model.dart';

class InvestRepositoryImpl implements InvestRepository {
  final InvestRemoteDataSource remoteDataSource;

  InvestRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Stock>> getStocks() async {
    final List<StockModel> models =
        await remoteDataSource.fetchStocks();

    // Model → Entity (karena StockModel extends Stock, ini aman)
    return models;
  }
}
