import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/ai_insight_service.dart';
import '../services/finance_service.dart';

class AiInsightProvider extends ChangeNotifier {
  final AiInsightService _aiService;
  final FinanceService _financeService;

  List<AiInsightModel> _insights = [];
  bool _isLoading = false;

  AiInsightProvider({
    required AiInsightService aiService,
    required FinanceService financeService,
  })  : _aiService = aiService, // ignore: prefer_initializing_formals
        _financeService = financeService; // ignore: prefer_initializing_formals

  List<AiInsightModel> get activeInsights =>
      _insights.where((i) => !i.isDismissed).toList();

  bool get isLoading => _isLoading;

  Future<void> generateInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      _insights = await _aiService.getInsights(
        transactions: _financeService.transactions,
        budget: _financeService.currentBudget,
        recurring: _financeService.recurringPayments,
        goals: _financeService.savingsGoals,
        totalIncome: _financeService.monthlyIncome,
        totalExpense: _financeService.monthlyExpense,
      );
    } catch (_) {
      _insights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void dismissInsight(String id) {
    final index = _insights.indexWhere((i) => i.id == id);
    if (index != -1) {
      _insights[index] = _insights[index].copyWith(isDismissed: true);
      notifyListeners();
    }
  }
}
