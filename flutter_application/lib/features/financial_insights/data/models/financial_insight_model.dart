import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';

class FinancialInsightModel extends FinancialInsight {
  const FinancialInsightModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.description,
    super.data,
    required super.createdAt,
    required super.isRead,
  });

  factory FinancialInsightModel.fromJson(Map<String, dynamic> json) {
    return FinancialInsightModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'description': description,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
}
