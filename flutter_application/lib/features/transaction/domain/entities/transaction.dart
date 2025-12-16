import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final String type;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        categoryName,
        type,
        amount,
        description,
        date,
        createdAt,
      ];
}
