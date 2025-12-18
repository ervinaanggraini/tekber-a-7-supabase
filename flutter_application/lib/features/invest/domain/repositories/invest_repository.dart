import '../entities/stock.dart';

abstract class InvestRepository {
  Future<List<Stock>> getStocks();
}
