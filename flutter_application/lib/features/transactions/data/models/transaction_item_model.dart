import '../../domain/entities/transaction_item.dart';

class TransactionItemModel extends TransactionItem {
  const TransactionItemModel({
    required super.id,
    required super.transactionId,
    required super.name,
    required super.quantity,
    required super.price,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) {
    return TransactionItemModel(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'transaction_id': transactionId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
