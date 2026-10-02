import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/finance_service.dart';
import '../services/notification_service.dart';

class SavingsProvider extends ChangeNotifier {
  final FinanceService _financeService;
  final NotificationService _notificationService;

  SavingsProvider({
    required FinanceService financeService,
    required NotificationService notificationService,
  })  : _financeService = financeService, // ignore: prefer_initializing_formals
        _notificationService = notificationService; // ignore: prefer_initializing_formals

  List<SavingsGoalModel> get goals => _financeService.savingsGoals;

  double get totalTarget =>
      goals.fold(0.0, (sum, g) => sum + g.targetAmount);

  double get totalSaved =>
      goals.fold(0.0, (sum, g) => sum + g.currentAmount);

  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
    double initialContribution = 0.0,
    String? notes,
    int? colorValue,
  }) async {
    await _financeService.addGoal(
      title: title,
      targetAmount: targetAmount,
      deadline: deadline,
      initialContribution: initialContribution,
      notes: notes,
      colorValue: colorValue,
    );
    notifyListeners();
  }

  Future<void> contribute(String goalId, double amount) async {
    await _financeService.contributeToGoal(goalId, amount);
    final goal = goals.firstWhere((g) => g.id == goalId);
    if (goal.isCompleted) {
      _notificationService.addNotification(
        NotificationModel(
          id: 'goal_completed_${goal.id}',
          title: 'Goal Achieved! 🎉',
          body: 'Congratulations! You reached your goal for "${goal.title}".',
          type: NotificationType.goalProgress,
          timestamp: DateTime.now(),
          actionRoute: '/main/savings',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _financeService.deleteGoal(id);
    notifyListeners();
  }
}
