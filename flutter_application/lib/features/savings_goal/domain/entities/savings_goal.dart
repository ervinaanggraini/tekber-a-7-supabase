import 'package:equatable/equatable.dart';

class SavingsGoal extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final bool isCompleted;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    this.icon,
    this.color,
    required this.isCompleted,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  double get remainingAmount => targetAmount - currentAmount;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        targetAmount,
        currentAmount,
        targetDate,
        icon,
        color,
        isCompleted,
      ];
}
