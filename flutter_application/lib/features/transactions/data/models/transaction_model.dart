import 'package:flutter_application/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_application/features/transactions/data/models/category_model.dart';
import 'package:flutter_application/features/transactions/data/models/transaction_item_model.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.type,
    required super.amount,
    super.description,
    super.notes,
    required super.transactionDate,
    super.transactionTime,
    required super.inputMethod,
    super.receiptImageUrl,
    super.merchantName,
    required super.createdAt,
    super.items,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      transactionTime: json['transaction_time'] != null
          ? DateTime.parse('1970-01-01 ${json['transaction_time']}')
          : null,
      inputMethod: json['input_method'] as String? ?? 'manual',
      receiptImageUrl: json['receipt_image_url'] as String?,
      merchantName: json['merchant_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List).map((it) => TransactionItemModel.fromJson(it as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'category_id': category.id,
      'type': type,
      'amount': amount,
      'description': description,
      'notes': notes,
      'transaction_date': transactionDate.toIso8601String().split('T')[0],
      'transaction_time': transactionTime?.toIso8601String().split('T')[1].split('.')[0],
      'input_method': inputMethod,
      'receipt_image_url': receiptImageUrl,
      'merchant_name': merchantName,
    };
    
    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Include items if present
    if (items != null) {
      json['items'] = items!.map((it) {
        if (it is TransactionItemModel) return it.toJson();
        return {
          'name': it.name,
          'quantity': it.quantity,
          'price': it.price,
        };
      }).toList();
    }
    
    return json;
  }
}
