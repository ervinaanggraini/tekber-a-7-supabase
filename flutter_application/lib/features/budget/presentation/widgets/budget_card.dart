import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/core/constants/app_colors.dart';
import 'package:flutter_application/features/budget/domain/entities/budget.dart';
import 'package:intl/intl.dart';

class BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetCard({
    super.key,
    required this.budget,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = budget.progress.clamp(0.0, 1.0);
    final isOverBudget = budget.isOverBudget;
    final color = isOverBudget
        ? Colors.red
        : progress > (budget.alertThreshold / 100)
            ? Colors.orange
            : AppColors.b93160;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      budget.category?.icon ?? '💰',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          budget.period == 'monthly' ? 'Bulanan' : budget.period,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black54),
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(budget.spentAmount),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'dari ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(budget.amount)}',
                    style: GoogleFonts.poppins(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOverBudget
                    ? 'Over budget sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(budget.spentAmount - budget.amount)}'
                    : 'Sisa ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(budget.remainingAmount)}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isOverBudget ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
