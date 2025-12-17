import '../models/stock_model.dart';

abstract class InvestRemoteDataSource {
  Future<List<StockModel>> fetchStocks();
}

class InvestRemoteDataSourceImpl implements InvestRemoteDataSource {
  @override
  Future<List<StockModel>> fetchStocks() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      StockModel(
        code: 'BBCA',
        name: 'Bank Central Asia',
        price: 9750,
        changePercent: 0.26,
      ),
      StockModel(
        code: 'GOTO',
        name: 'GoTo Gojek Tokopedia',
        price: 55,
        changePercent: -0.26,
      ),
    ];
  }
}
