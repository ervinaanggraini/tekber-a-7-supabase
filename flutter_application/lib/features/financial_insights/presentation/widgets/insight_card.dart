import 'package:flutter/material.dart';
import 'package:flutter_application/features/financial_insights/domain/entities/financial_insight.dart';

class InsightCard extends StatelessWidget {
  final FinancialInsight insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData iconData;

    switch (insight.type) {
      case 'spending_anomaly':
        cardColor = Colors.red.shade50;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'saving_opportunity':
        cardColor = Colors.green.shade50;
        iconData = Icons.savings_outlined;
        break;
      case 'budget_alert':
        cardColor = Colors.orange.shade50;
        iconData = Icons.notifications_active_outlined;
        break;
      case 'investment_tip':
        cardColor = Colors.blue.shade50;
        iconData = Icons.trending_up;
        break;
      default:
        cardColor = Colors.grey.shade50;
        iconData = Icons.lightbulb_outline;
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: Colors.black87),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!insight.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(insight.description),
            if (insight.data != null && insight.data!.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Example of rendering extra data if needed
              // Text(insight.data.toString(), style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}
