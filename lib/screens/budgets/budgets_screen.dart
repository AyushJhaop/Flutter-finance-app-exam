import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_widgets.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final budget = budgetProvider.currentBudget;

    if (budget == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(title: const Text('Budgets')),
        body: const Center(child: Text('No active budget configured')),
      );
    }

    final totalLimit = budget.totalLimit;
    final totalSpent = budget.totalSpent;
    final remaining = budget.remaining;
    final pct = budget.utilizationPercentage;

    final alertColor = pct >= 90
        ? AppColors.error
        : pct >= 80
            ? AppColors.warning
            : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Monthly Budgets',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Adjust Budget Limit',
            icon: const Icon(Icons.edit_note_rounded),
            onPressed: () => _showEditBudgetDialog(context, totalLimit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Budget Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: alertColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL MONTHLY BUDGET',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: alertColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${pct.toStringAsFixed(1)}% Used',
                          style: TextStyle(
                            fontSize: 11,
                            color: alertColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    CurrencyFormatter.formatINR(totalSpent),
                    style: AppTypography.headlineLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Budget Limit: ${CurrencyFormatter.formatINR(totalLimit)} (${CurrencyFormatter.formatINR(remaining)} left)',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: AppColors.bgSurface,
                      valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Category Breakdown',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            ...budget.categoryBudgets.map((cb) {
              final catPct = cb.utilizationPercentage;
              final catColor = catPct >= 100
                  ? AppColors.error
                  : catPct >= 80
                      ? AppColors.warning
                      : cb.category.color;

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.bgSurface,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cb.category.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cb.category.icon,
                            size: 18,
                            color: cb.category.color,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cb.category.displayName,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.formatINR(cb.spent)} / ${CurrencyFormatter.formatINR(cb.limit)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${catPct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: catColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: (cb.utilization).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.bgSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, double currentLimit) {
    final ctrl = TextEditingController(text: currentLimit.toInt().toString());
    final budgetProvider = context.read<BudgetProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Update Total Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set your total monthly spending ceiling.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: ctrl,
              label: 'Monthly Limit (₹)',
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newLimit = double.tryParse(ctrl.text.trim());
              if (newLimit != null && newLimit > 0) {
                final current = budgetProvider.currentBudget!;
                await budgetProvider.updateBudget(
                  totalLimit: newLimit,
                  categoryBudgets: current.categoryBudgets,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  AppSnackbar.showSuccess(context, 'Budget limit updated!');
                }
              }
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
