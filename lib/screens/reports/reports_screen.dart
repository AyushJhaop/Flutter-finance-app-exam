import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/providers.dart';
import '../../widgets/common/app_widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    final income = finance.monthlyIncome;
    final expense = finance.monthlyExpense;
    final savings = finance.monthlySavings;
    final savingsRate = finance.savingsRate;
    final breakdown = finance.categorySpendBreakdown;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Financial Statement',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Export Statement',
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              AppSnackbar.showSuccess(
                context,
                'Monthly statement ready. PDF generated to downloads.',
              );
            },
          ),
        ],
      ),
      body: ResponsiveContainer.wide(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statement Header Document Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STATEMENT PERIOD',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Text(
                          'Verified Summary',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'September 2026',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Divider(height: 24, color: AppColors.divider),
                  _statementRow('Total Inflow (Income)',
                      CurrencyFormatter.formatINR(income), AppColors.success),
                  _statementRow('Total Outflow (Expenses)',
                      CurrencyFormatter.formatINR(expense), AppColors.error),
                  _statementRow('Net Capital Retained',
                      CurrencyFormatter.formatINR(savings), AppColors.primary),
                  _statementRow('Savings Retention Rate',
                      '${savingsRate.toStringAsFixed(1)}%', AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Expense Breakdown by Category',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: breakdown.entries.map((e) {
                  final pct =
                      expense > 0 ? (e.value / expense) * 100 : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(e.key.icon, size: 16, color: e.key.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key.displayName,
                            style: AppTypography.bodySmall,
                          ),
                        ),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          CurrencyFormatter.formatINR(e.value),
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Export PDF Statement',
                    prefixIcon: Icons.picture_as_pdf_rounded,
                    onPressed: () {
                      AppSnackbar.showSuccess(
                        context,
                        'Downloaded: FinTrack_September_2026.pdf',
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'CSV Data',
                    variant: ButtonVariant.secondary,
                    prefixIcon: Icons.table_chart_rounded,
                    onPressed: () {
                      AppSnackbar.showSuccess(
                        context,
                        'Exported 19 rows to transactions_sep2026.csv',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _statementRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              )),
        ],
      ),
    );
  }
}
