import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/finance_service.dart';
import '../services/notification_service.dart';

class BudgetProvider extends ChangeNotifier {
  final FinanceService _financeService;
  final NotificationService _notificationService;

  BudgetProvider({
    required FinanceService financeService,
    required NotificationService notificationService,
  })  : _financeService = financeService, // ignore: prefer_initializing_formals
        _notificationService = notificationService; // ignore: prefer_initializing_formals

  BudgetModel? get currentBudget => _financeService.currentBudget;

  double get totalLimit => currentBudget?.totalLimit ?? 30000.0;
  double get totalSpent => currentBudget?.totalSpent ?? 0.0;
  double get remaining => currentBudget?.remaining ?? 0.0;
  double get utilizationPercentage =>
      currentBudget?.utilizationPercentage ?? 0.0;

  List<CategoryBudget> get categoryBudgets =>
      currentBudget?.categoryBudgets ?? [];

  BudgetAlertLevel get overallAlertLevel =>
      currentBudget?.overallAlertLevel ?? BudgetAlertLevel.normal;

  Future<void> updateBudget({
    required double totalLimit,
    required List<CategoryBudget> categoryBudgets,
  }) async {
    await _financeService.updateBudget(
      totalLimit: totalLimit,
      categoryBudgets: categoryBudgets,
    );
    if (currentBudget != null) {
      _notificationService.checkBudgetAlerts(currentBudget!);
    }
    notifyListeners();
  }

  void syncWithTransactions() {
    notifyListeners();
  }
}
