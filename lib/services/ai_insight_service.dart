import '../models/ai_insight_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_payment_model.dart';
import '../models/savings_goal_model.dart';
import '../core/utils/currency_formatter.dart';

abstract class IAiInsightProvider {
  Future<List<AiInsightModel>> generateInsights({
    required List<TransactionModel> transactions,
    required BudgetModel? budget,
    required List<RecurringPaymentModel> recurring,
    required List<SavingsGoalModel> goals,
    required double totalIncome,
    required double totalExpense,
  });
}

/// Fallback / Local Rule-based Insight Engine
/// Deterministic, fast, works offline, and complies with safety standards.
class LocalRuleBasedInsightEngine implements IAiInsightProvider {
  @override
  Future<List<AiInsightModel>> generateInsights({
    required List<TransactionModel> transactions,
    required BudgetModel? budget,
    required List<RecurringPaymentModel> recurring,
    required List<SavingsGoalModel> goals,
    required double totalIncome,
    required double totalExpense,
  }) async {
    final List<AiInsightModel> insights = [];
    final now = DateTime.now();

    // 1. Food / Dining spike insight
    final foodExpenses = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == TransactionCategory.food)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (foodExpenses > 4000) {
      final formattedFood = CurrencyFormatter.formatINR(foodExpenses);
      insights.add(
        AiInsightModel(
          id: 'insight_food_spike',
          type: InsightType.categorySpike,
          title: 'Food & Dining Trend',
          description:
              'You have spent $formattedFood on food this month. That is approximately 21% above your recent historical average of ₹4,300.',
          recommendation:
              'Consider tracking weekly delivery orders on Swiggy and Zomato to maintain your ₹6,000 monthly food budget.',
          category: TransactionCategory.food,
          impactAmount: foodExpenses - 4300,
          confidenceScore: 0.92,
          createdAt: now,
        ),
      );
    }

    // 2. Budget Utilisation Risk
    if (budget != null && budget.utilization >= 0.75) {
      final utilPct = (budget.utilization * 100).toStringAsFixed(1);
      final remainingDays = DateTime(now.year, now.month + 1, 0).day - now.day;
      insights.add(
        AiInsightModel(
          id: 'insight_budget_pacing',
          type: InsightType.budgetRisk,
          title: 'Budget Pace Warning',
          description:
              'You have consumed $utilPct% of your ₹${budget.totalLimit.toInt()} monthly budget with $remainingDays days left in the billing cycle.',
          recommendation:
              'At your current daily run-rate, discretionary spending in Shopping and Entertainment may exceed target limits.',
          impactAmount: budget.remaining,
          confidenceScore: 0.88,
          createdAt: now,
        ),
      );
    }

    // 3. Positive Savings Rate Insight
    if (totalIncome > 0 && totalExpense > 0) {
      final savings = totalIncome - totalExpense;
      final savingsRate = (savings / totalIncome) * 100;
      if (savingsRate >= 50) {
        insights.add(
          AiInsightModel(
            id: 'insight_savings_rate',
            type: InsightType.positiveTrend,
            title: 'Strong Savings Rate',
            description:
                'Your current savings rate is ${savingsRate.toStringAsFixed(1)}% (${CurrencyFormatter.formatINR(savings)} saved from ${CurrencyFormatter.formatINR(totalIncome)} income).',
            recommendation:
                'You are well positioned to allocate surplus savings into your MacBook Pro or Emergency Fund goals.',
            impactAmount: savings,
            confidenceScore: 0.95,
            createdAt: now,
          ),
        );
      }
    }

    // 4. Upcoming Recurring Commitments
    if (recurring.isNotEmpty) {
      final totalRecurring =
          recurring.fold(0.0, (sum, r) => sum + r.amount);
      final activeCount = recurring.length;
      insights.add(
        AiInsightModel(
          id: 'insight_recurring_summary',
          type: InsightType.recurringReminder,
          title: 'Scheduled Subscriptions',
          description:
              'You have $activeCount active subscriptions & recurring bills totaling ${CurrencyFormatter.formatINR(totalRecurring)} scheduled across this cycle.',
          recommendation:
              'Verify that automated debit mandates on your HDFC and ICICI accounts are sufficiently funded.',
          impactAmount: totalRecurring,
          confidenceScore: 0.96,
          createdAt: now,
        ),
      );
    }

    // 5. Savings Milestone Progress
    for (final goal in goals) {
      if (goal.progress >= 0.5 && !goal.isCompleted) {
        insights.add(
          AiInsightModel(
            id: 'insight_goal_${goal.id}',
            type: InsightType.savingsMilestone,
            title: '${goal.title} Progress',
            description:
                'You have reached ${goal.progressPercentage.toStringAsFixed(0)}% of your target for "${goal.title}" (${CurrencyFormatter.formatINR(goal.currentAmount)} / ${CurrencyFormatter.formatINR(goal.targetAmount)}).',
            recommendation:
                'Only ${CurrencyFormatter.formatINR(goal.remainingAmount)} remaining. You are on track to complete this goal before ${goal.daysRemaining} days.',
            impactAmount: goal.remainingAmount,
            confidenceScore: 0.90,
            createdAt: now,
          ),
        );
        break; // Show top goal insight
      }
    }

    return insights;
  }
}

/// AiInsightService with safety wrappers and fallback
class AiInsightService {
  final IAiInsightProvider _provider;

  AiInsightService({IAiInsightProvider? provider})
      : _provider = provider ?? LocalRuleBasedInsightEngine();

  Future<List<AiInsightModel>> getInsights({
    required List<TransactionModel> transactions,
    required BudgetModel? budget,
    required List<RecurringPaymentModel> recurring,
    required List<SavingsGoalModel> goals,
    required double totalIncome,
    required double totalExpense,
  }) async {
    try {
      return await _provider.generateInsights(
        transactions: transactions,
        budget: budget,
        recurring: recurring,
        goals: goals,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );
    } catch (_) {
      // Fallback guarantees UI stability
      return LocalRuleBasedInsightEngine().generateInsights(
        transactions: transactions,
        budget: budget,
        recurring: recurring,
        goals: goals,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );
    }
  }
}
