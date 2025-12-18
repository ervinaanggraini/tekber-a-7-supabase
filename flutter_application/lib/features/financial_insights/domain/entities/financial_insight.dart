import 'package:equatable/equatable.dart';

class FinancialInsight extends Equatable {
  final String id;
  final String userId;
  final String type; // 'spending_anomaly', 'saving_opportunity', 'budget_alert', 'investment_tip'
  final String title;
  final String description;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  const FinancialInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.data,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        description,
        data,
        createdAt,
        isRead,
      ];
}
