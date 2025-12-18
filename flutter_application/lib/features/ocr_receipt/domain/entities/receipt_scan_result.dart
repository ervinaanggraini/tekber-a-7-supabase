import 'package:equatable/equatable.dart';

class ReceiptScanResult extends Equatable {
  final String merchantName;
  final double totalAmount;
  final DateTime date;
  final List<ReceiptItem> items;

  const ReceiptScanResult({
    required this.merchantName,
    required this.totalAmount,
    required this.date,
    required this.items,
  });

  @override
  List<Object?> get props => [merchantName, totalAmount, date, items];
}

class ReceiptItem extends Equatable {
  final String name;
  final double price;
  final int quantity;

  const ReceiptItem({
    required this.name,
    required this.price,
    required this.quantity,
  });

  @override
  List<Object?> get props => [name, price, quantity];
}
