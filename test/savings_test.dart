import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/models/savings_goal_model.dart';

void main() {
  group('SavingsGoalModel calculations', () {
    test('calculates progress and remaining amount matching case study', () {
      final goal = SavingsGoalModel(
        id: 'goal_macbook',
        title: 'MacBook Pro',
        targetAmount: 120000.0,
        currentAmount: 72000.0,
        deadline: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      // Progress = 72000 / 120000 = 0.60 (60%)
      expect(goal.progress, equals(0.60));
      expect(goal.progressPercentage, equals(60.0));
      // Remaining = 120000 - 72000 = 48000
      expect(goal.remainingAmount, equals(48000.0));
      expect(goal.isCompleted, isFalse);
    });

    test('marks goal as completed when saved amount equals or exceeds target', () {
      final goal = SavingsGoalModel(
        id: 'goal_emergency',
        title: 'Emergency Reserve',
        targetAmount: 100000.0,
        currentAmount: 100000.0,
        deadline: DateTime.now().add(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );

      expect(goal.progress, equals(1.0));
      expect(goal.progressPercentage, equals(100.0));
      expect(goal.remainingAmount, equals(0.0));
      expect(goal.isCompleted, isTrue);
    });
  });
}
