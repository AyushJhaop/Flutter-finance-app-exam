import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/finance_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceService _financeService;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  TransactionCategory? _selectedCategory;
  TransactionType? _selectedType;
  DateTime? _selectedDate;

  FinanceProvider({required FinanceService financeService})
      : _financeService = financeService; // ignore: prefer_initializing_formals

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TransactionCategory? get selectedCategory => _selectedCategory;
  TransactionType? get selectedType => _selectedType;
  DateTime? get selectedDate => _selectedDate;

  List<AccountModel> get accounts => _financeService.accounts;
  List<TransactionModel> get allTransactions => _financeService.transactions;
  List<RecurringPaymentModel> get recurringPayments =>
      _financeService.recurringPayments;

  double get totalNetBalance => _financeService.totalNetBalance;
  double get totalAssets => _financeService.totalAssets;
  double get totalLiabilities => _financeService.totalLiabilities;
  double get monthlyIncome => _financeService.monthlyIncome;
  double get monthlyExpense => _financeService.monthlyExpense;
  double get monthlySavings => (monthlyIncome - monthlyExpense).clamp(0, double.infinity);
  double get savingsRate =>
      monthlyIncome > 0 ? ((monthlyIncome - monthlyExpense) / monthlyIncome) * 100 : 0.0;

  Map<TransactionCategory, double> get categorySpendBreakdown =>
      _financeService.categorySpendBreakdown;

  List<TransactionModel> get recentTransactions =>
      _financeService.transactions.take(5).toList();

  /// Filtered transactions based on search, category, type, and date
  List<TransactionModel> get filteredTransactions {
    return _financeService.transactions.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesMerchant = t.merchant.toLowerCase().contains(q);
        final matchesCategory = t.category.displayName.toLowerCase().contains(q);
        final matchesNotes = t.notes?.toLowerCase().contains(q) ?? false;
        if (!matchesMerchant && !matchesCategory && !matchesNotes) return false;
      }

      if (_selectedCategory != null && t.category != _selectedCategory) {
        return false;
      }

      if (_selectedType != null && t.type != _selectedType) {
        return false;
      }

      if (_selectedDate != null) {
        if (t.date.year != _selectedDate!.year ||
            t.date.month != _selectedDate!.month ||
            t.date.day != _selectedDate!.day) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _financeService.initialize();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _financeService.refresh();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(TransactionCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setTypeFilter(TransactionType? type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedType = null;
    _selectedDate = null;
    notifyListeners();
  }

  Future<TransactionModel> addTransaction({
    required String merchant,
    required double amount,
    TransactionCategory? category,
    required String accountId,
    required TransactionType type,
    DateTime? date,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final tx = await _financeService.addTransaction(
        merchant: merchant,
        amount: amount,
        category: category,
        accountId: accountId,
        type: type,
        date: date,
        notes: notes,
      );
      return tx;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _financeService.deleteTransaction(id);
    notifyListeners();
  }
}
