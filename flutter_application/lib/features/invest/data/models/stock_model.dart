import '../../domain/entities/stock.dart';

class StockModel extends Stock {
  const StockModel({
    required String code,
    required String name,
    required double price,
    required double changePercent,
  }) : super(
          code: code,
          name: name,
          price: price,
          changePercent: changePercent,
        );

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      code: json['code'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      changePercent: (json['change_percent'] as num).toDouble(),
    );
  }
}
