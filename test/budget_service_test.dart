import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/budget_model.dart';
import 'package:fintrack/models/transaction_model.dart';

void main() {
  group('BudgetModel calculations', () {
    test('calculates utilisation and remaining amount matching case study', () {
      const budget = BudgetModel(
        id: 'budget_test',
        monthYear: '2026-09',
        totalLimit: 30000.0,
        categoryBudgets: [
          CategoryBudget(
            category: TransactionCategory.food,
            limit: 6000.0,
            spent: 5200.0,
          ),
          CategoryBudget(
            category: TransactionCategory.shopping,
            limit: 5000.0,
            spent: 4800.0,
          ),
          CategoryBudget(
            category: TransactionCategory.travel,
            limit: 4000.0,
            spent: 3100.0,
          ),
          CategoryBudget(
            category: TransactionCategory.bills,
            limit: 7000.0,
            spent: 2600.0,
          ),
          CategoryBudget(
            category: TransactionCategory.entertainment,
            limit: 3000.0,
            spent: 1980.0,
          ),
          CategoryBudget(
            category: TransactionCategory.other,
            limit: 5000.0,
            spent: 6000.0,
          ),
        ],
      );

      // Total spent = 5200 + 4800 + 3100 + 2600 + 1980 + 6000 = 23680
      expect(budget.totalSpent, equals(23680.0));
      // Remaining = 30000 - 23680 = 6320
      expect(budget.remaining, equals(6320.0));
      // Utilisation = 23680 / 30000 = 78.9333%
      expect(budget.utilizationPercentage, closeTo(78.93, 0.05));
    });

    test('determines correct alert thresholds for category budgets', () {
      const normal = CategoryBudget(
        category: TransactionCategory.bills,
        limit: 10000,
        spent: 5000, // 50%
      );
      expect(normal.alertLevel, equals(BudgetAlertLevel.normal));

      const warning = CategoryBudget(
        category: TransactionCategory.food,
        limit: 10000,
        spent: 8500, // 85%
      );
      expect(warning.alertLevel, equals(BudgetAlertLevel.warning));

      const strongWarning = CategoryBudget(
        category: TransactionCategory.shopping,
        limit: 10000,
        spent: 9500, // 95%
      );
      expect(strongWarning.alertLevel, equals(BudgetAlertLevel.strongWarning));

      const exceeded = CategoryBudget(
        category: TransactionCategory.other,
        limit: 10000,
        spent: 10500, // 105%
      );
      expect(exceeded.alertLevel, equals(BudgetAlertLevel.exceeded));
    });
  });
}
