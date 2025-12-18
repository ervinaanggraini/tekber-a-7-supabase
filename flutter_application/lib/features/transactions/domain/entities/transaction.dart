import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';
import 'package:flutter_application/features/transactions/domain/entities/transaction_item.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final Category category;
  final String type; // 'income' or 'expense'
  final double amount;
  final String? description;
  final String? notes;
  final DateTime transactionDate;
  final DateTime? transactionTime;
  final String inputMethod; // 'manual', 'ai_chat', 'ocr', 'voice'
  final String? receiptImageUrl;
  final String? merchantName;
  final DateTime createdAt;
  final List<TransactionItem>? items;

  const Transaction({
    required this.id,
    required this.userId,
    required this.category,
    required this.type,
    required this.amount,
    this.description,
    this.notes,
    required this.transactionDate,
    this.transactionTime,
    required this.inputMethod,
    this.receiptImageUrl,
    this.merchantName,
    required this.createdAt,
    this.items,
  });

  DateTime get date => transactionDate;
  String get categoryName => category.name;
  int? get itemsCount => items?.length;

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        type,
        amount,
        description,
        notes,
        transactionDate,
        transactionTime,
        inputMethod,
        receiptImageUrl,
        merchantName,
        createdAt,
        items,
      ];
}
