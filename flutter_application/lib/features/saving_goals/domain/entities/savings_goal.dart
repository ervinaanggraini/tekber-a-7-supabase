class SavingsGoal {
  final String id;
  final double targetAmount;
  final DateTime deadline;

  SavingsGoal({
    required this.id,
    required this.targetAmount,
    required this.deadline,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      deadline: DateTime.parse(json['deadline']),
    );
  }
}