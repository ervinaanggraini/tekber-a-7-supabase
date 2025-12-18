import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/transactions/domain/entities/category.dart';

class Budget extends Equatable {
  final String id;
  final String userId;
  final String? categoryId;
  final Category? category;
  final String name;
  final double amount;
  final double spentAmount;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int alertThreshold;
  final bool isActive;

  const Budget({
    required this.id,
    required this.userId,
    this.categoryId,
    this.category,
    required this.name,
    required this.amount,
    this.spentAmount = 0,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.alertThreshold,
    required this.isActive,
  });

  double get progress => amount > 0 ? spentAmount / amount : 0;
  bool get isOverBudget => spentAmount > amount;
  double get remainingAmount => amount - spentAmount;

  Budget copyWith({
    String? id,
    String? userId,
    String? categoryId,
    Category? category,
    String? name,
    double? amount,
    double? spentAmount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    int? alertThreshold,
    bool? isActive,
  }) {
    return Budget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spentAmount: spentAmount ?? this.spentAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        category,
        name,
        amount,
        spentAmount,
        period,
        startDate,
        endDate,
        alertThreshold,
        isActive,
      ];
}
