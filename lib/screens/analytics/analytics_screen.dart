import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    final income = finance.monthlyIncome;
    final expense = finance.monthlyExpense;
    final savings = finance.monthlySavings;
    final savingsRate = finance.savingsRate;

    final categoryBreakdown = finance.categorySpendBreakdown;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text(
          'Financial Analytics',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Financial Health / Savings Rate KPI ────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVINGS RATE',
                        style: AppTypography.labelSmall.copyWith(
                          letterSpacing: 1.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          savingsRate >= 50 ? 'Excellent Pace' : 'Moderate Pace',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${savingsRate.toStringAsFixed(1)}%',
                        style: AppTypography.displaySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'of income retained',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: (savingsRate / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.bgSurface,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _kpiItem('Income', CurrencyFormatter.formatINR(income),
                          AppColors.success),
                      _kpiItem('Expenses', CurrencyFormatter.formatINR(expense),
                          AppColors.error),
                      _kpiItem('Net Saved', CurrencyFormatter.formatINR(savings),
                          AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ─── Income vs Expenses Bar Chart ──────────────────────────────
            Text(
              'Income vs Expenses',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 80000,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '₹${rod.toY.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox();
                          return Text(
                            '₹${(val / 1000).toInt()}k',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          switch (val.toInt()) {
                            case 0:
                              return const Text('July',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary));
                            case 1:
                              return const Text('August',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary));
                            case 2:
                              return const Text('September',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary));
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => const FlLine(
                      color: AppColors.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    // July
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                            toY: 72000,
                            color: AppColors.success.withValues(alpha: 0.7),
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                        BarChartRodData(
                            toY: 26500,
                            color: AppColors.error.withValues(alpha: 0.7),
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                    // August
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                            toY: 72000,
                            color: AppColors.success.withValues(alpha: 0.7),
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                        BarChartRodData(
                            toY: 28900,
                            color: AppColors.error.withValues(alpha: 0.7),
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                    // September (Current)
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                            toY: income,
                            color: AppColors.success,
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                        BarChartRodData(
                            toY: expense,
                            color: AppColors.error,
                            width: 14,
                            borderRadius: BorderRadius.circular(4)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendIndicator(AppColors.success, 'Total Income'),
                const SizedBox(width: AppSpacing.lg),
                _legendIndicator(AppColors.error, 'Total Expenses'),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ─── Category Spending Breakdown (Donut Chart) ──────────────────
            Text(
              'Spending by Category',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedPieIndex = -1;
                                return;
                              }
                              _touchedPieIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 46,
                        sections: _buildPieSections(categoryBreakdown),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Legend Items
                  ...categoryBreakdown.entries.map((entry) {
                    final cat = entry.key;
                    final amt = entry.value;
                    final pct = expense > 0 ? (amt / expense) * 100 : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cat.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat.displayName,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            CurrencyFormatter.formatINR(amt),
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ─── Spending Trend (Line Chart) ───────────────────────────────
            Text(
              '30-Day Spending Trend',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 200,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => const FlLine(
                      color: AppColors.borderSubtle,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (val, meta) => Text(
                          '₹${(val / 1000).toInt()}k',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          switch (val.toInt()) {
                            case 1:
                              return const Text('W1',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary));
                            case 2:
                              return const Text('W2',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary));
                            case 3:
                              return const Text('W3',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary));
                            case 4:
                              return const Text('W4',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary));
                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 1,
                  maxX: 4,
                  minY: 0,
                  maxY: 12000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(1, 4200),
                        FlSpot(2, 6800),
                        FlSpot(3, 8100),
                        FlSpot(4, 4580),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _kpiItem(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _legendIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<TransactionCategory, double> breakdown) {
    int i = 0;
    final total = breakdown.values.fold(0.0, (s, v) => s + v);

    return breakdown.entries.map((e) {
      final isTouched = i == _touchedPieIndex;
      final fontSize = isTouched ? 14.0 : 11.0;
      final radius = isTouched ? 50.0 : 42.0;
      final pct = total > 0 ? (e.value / total) * 100 : 0.0;
      i++;

      return PieChartSectionData(
        color: e.key.color,
        value: e.value,
        title: '${pct.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
