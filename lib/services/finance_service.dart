import 'dart:async';
import '../models/models.dart';
import 'storage_service.dart';
import 'categorisation_service.dart';
import 'recurring_detection_service.dart';

class FinanceService {
  final StorageService _storage;
  final CategorisationService _categorisationService;
  final RecurringDetectionService _recurringDetectionService;

  List<AccountModel> _accounts = [];
  List<TransactionModel> _transactions = [];
  BudgetModel? _currentBudget;
  List<SavingsGoalModel> _savingsGoals = [];
  List<RecurringPaymentModel> _recurringPayments = [];

  FinanceService({
    required StorageService storage,
    CategorisationService? categorisationService,
    RecurringDetectionService? recurringDetectionService,
  })  : _storage = storage, // ignore: prefer_initializing_formals
        _categorisationService =
            categorisationService ?? CategorisationService(),
        _recurringDetectionService =
            recurringDetectionService ?? RecurringDetectionService();

  // Getters
  List<AccountModel> get accounts => List.unmodifiable(_accounts);
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  BudgetModel? get currentBudget => _currentBudget;
  List<SavingsGoalModel> get savingsGoals => List.unmodifiable(_savingsGoals);
  List<RecurringPaymentModel> get recurringPayments =>
      List.unmodifiable(_recurringPayments);

  double get totalNetBalance {
    double total = 0.0;
    for (final acc in _accounts) {
      if (acc.type == AccountType.creditCard) {
        total -= acc.balance; // Credit card is a liability/debt
      } else {
        total += acc.balance;
      }
    }
    return total;
  }

  double get totalAssets {
    return _accounts
        .where((a) => a.type != AccountType.creditCard)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  double get totalLiabilities {
    return _accounts
        .where((a) => a.type == AccountType.creditCard)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<TransactionCategory, double> get categorySpendBreakdown {
    final now = DateTime.now();
    final Map<TransactionCategory, double> result = {};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        result[t.category] = (result[t.category] ?? 0.0) + t.amount;
      }
    }
    return result;
  }

  // ─── Initialization & Persistence ──────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Try restoring from offline cache
    final cachedData = _storage.getCachedData('fintrack_finance_cache');
    if (cachedData != null) {
      _loadFromCache(cachedData);
    } else {
      // 2. Load realistic FinTech mock dataset
      _seedRealisticFinancialData();
      await _persistToCache();
    }

    _recalculateCategoryBudgets();
  }

  Future<void> refresh() async {
    // Simulate network delay for mock backend sync
    await Future.delayed(const Duration(milliseconds: 600));
    _storage.setLastSynced(DateTime.now());
    await _persistToCache();
  }

  Future<void> _persistToCache() async {
    final cache = {
      'accounts': _accounts.map((a) => a.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'budget': _currentBudget?.toJson(),
      'goals': _savingsGoals.map((g) => g.toJson()).toList(),
      'recurring': _recurringPayments.map((r) => r.toJson()).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    };
    await _storage.cacheData('fintrack_finance_cache', cache);
    await _storage.setLastSynced(DateTime.now());
  }

  void _loadFromCache(Map<String, dynamic> cache) {
    if (cache['accounts'] != null) {
      _accounts = (cache['accounts'] as List)
          .map((a) => AccountModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }
    if (cache['transactions'] != null) {
      _transactions = (cache['transactions'] as List)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();
    }
    if (cache['budget'] != null) {
      _currentBudget =
          BudgetModel.fromJson(cache['budget'] as Map<String, dynamic>);
    }
    if (cache['goals'] != null) {
      _savingsGoals = (cache['goals'] as List)
          .map((g) => SavingsGoalModel.fromJson(g as Map<String, dynamic>))
          .toList();
    }
    if (cache['recurring'] != null) {
      _recurringPayments = (cache['recurring'] as List)
          .map((r) => RecurringPaymentModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }
  }

  // ─── Transaction Operations ───────────────────────────────────────────────

  Future<TransactionModel> addTransaction({
    required String merchant,
    required double amount,
    TransactionCategory? category,
    required String accountId,
    required TransactionType type,
    DateTime? date,
    String? notes,
  }) async {
    final effectiveCategory = category ??
        _categorisationService.categorise(merchant, description: notes);

    final account = _accounts.firstWhere(
      (a) => a.id == accountId,
      orElse: () => _accounts.first,
    );

    final tx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      merchant: merchant,
      amount: amount,
      category: effectiveCategory,
      accountId: account.id,
      accountName: account.name,
      date: date ?? DateTime.now(),
      type: type,
      status: TransactionStatus.completed,
      notes: notes,
    );

    _transactions.insert(0, tx);

    // Update account balance
    _updateAccountBalance(account.id, amount, type);

    // Check if new recurring item detected
    final newRecurring =
        _recurringDetectionService.detectRecurring(_transactions);
    if (newRecurring.isNotEmpty) {
      for (final r in newRecurring) {
        if (!_recurringPayments.any((item) => item.merchant.toLowerCase() == r.merchant.toLowerCase())) {
          _recurringPayments.add(r);
        }
      }
    }

    _recalculateCategoryBudgets();
    await _persistToCache();
    return tx;
  }

  Future<void> deleteTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final tx = _transactions.removeAt(index);
      // Revert account balance
      final reverseType = tx.type == TransactionType.expense
          ? TransactionType.income
          : TransactionType.expense;
      _updateAccountBalance(tx.accountId, tx.amount, reverseType);
      _recalculateCategoryBudgets();
      await _persistToCache();
    }
  }

  void _updateAccountBalance(
      String accountId, double amount, TransactionType type) {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      final acc = _accounts[idx];
      double newBalance = acc.balance;
      if (acc.type == AccountType.creditCard) {
        // Expense increases credit card dues; income/payment decreases dues
        newBalance = type == TransactionType.expense
            ? acc.balance + amount
            : acc.balance - amount;
      } else {
        newBalance = type == TransactionType.income
            ? acc.balance + amount
            : acc.balance - amount;
      }
      _accounts[idx] = acc.copyWith(balance: newBalance);
    }
  }

  void _recalculateCategoryBudgets() {
    if (_currentBudget == null) return;
    final breakdown = categorySpendBreakdown;

    final updatedCategoryBudgets = _currentBudget!.categoryBudgets.map((cb) {
      final spent = breakdown[cb.category] ?? 0.0;
      return cb.copyWith(spent: spent);
    }).toList();

    _currentBudget =
        _currentBudget!.copyWith(categoryBudgets: updatedCategoryBudgets);
  }

  // ─── Budget Operations ───────────────────────────────────────────────────

  Future<void> updateBudget({
    required double totalLimit,
    required List<CategoryBudget> categoryBudgets,
  }) async {
    _currentBudget = _currentBudget?.copyWith(
          totalLimit: totalLimit,
          categoryBudgets: categoryBudgets,
        ) ??
        BudgetModel(
          id: 'budget_2026_09',
          monthYear: '2026-09',
          totalLimit: totalLimit,
          categoryBudgets: categoryBudgets,
        );
    _recalculateCategoryBudgets();
    await _persistToCache();
  }

  // ─── Savings Goals Operations ────────────────────────────────────────────

  Future<SavingsGoalModel> addGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
    double initialContribution = 0.0,
    String? notes,
    int? colorValue,
  }) async {
    final goal = SavingsGoalModel(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetAmount: targetAmount,
      currentAmount: initialContribution,
      deadline: deadline,
      notes: notes,
      createdAt: DateTime.now(),
      colorValue: colorValue ?? 0xFF00D4AA,
    );
    _savingsGoals.add(goal);
    await _persistToCache();
    return goal;
  }

  Future<void> contributeToGoal(String goalId, double amount) async {
    final index = _savingsGoals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final g = _savingsGoals[index];
      _savingsGoals[index] = g.copyWith(
        currentAmount: (g.currentAmount + amount).clamp(0, g.targetAmount * 1.5),
      );
      await _persistToCache();
    }
  }

  Future<void> deleteGoal(String id) async {
    _savingsGoals.removeWhere((g) => g.id == id);
    await _persistToCache();
  }

  // ─── Seed Data ────────────────────────────────────────────────────────────

  void _seedRealisticFinancialData() {
    final now = DateTime.now();

    // 1. Accounts
    _accounts = [
      AccountModel(
        id: 'acc_hdfc',
        name: 'HDFC Bank Salary Account',
        institution: 'HDFC Bank',
        type: AccountType.bank,
        balance: 42500.0,
        accountNumberLast4: '4821',
        lastSynced: now,
      ),
      AccountModel(
        id: 'acc_sbi',
        name: 'SBI Savings Account',
        institution: 'State Bank of India',
        type: AccountType.bank,
        balance: 25000.0,
        accountNumberLast4: '9104',
        lastSynced: now,
      ),
      AccountModel(
        id: 'acc_icici_cc',
        name: 'ICICI Coral Credit Card',
        institution: 'ICICI Bank',
        type: AccountType.creditCard,
        balance: 8450.0,
        accountNumberLast4: '3319',
        lastSynced: now,
      ),
      AccountModel(
        id: 'acc_upi_wallet',
        name: 'UPI / Paytm Wallet',
        institution: 'UPI Auto-wallet',
        type: AccountType.wallet,
        balance: 6500.0,
        accountNumberLast4: '8872',
        lastSynced: now,
      ),
    ];

    // 2. Realistic transactions matching Case Study
    _transactions = [
      TransactionModel(
        id: 'tx_01',
        merchant: 'Swiggy',
        amount: 420.0,
        category: TransactionCategory.food,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(hours: 2)),
        type: TransactionType.expense,
        notes: 'Lunch delivery with colleagues',
      ),
      TransactionModel(
        id: 'tx_02',
        merchant: 'Starbucks Coffee',
        amount: 380.0,
        category: TransactionCategory.food,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(hours: 6)),
        type: TransactionType.expense,
        notes: 'Cold brew & pastry',
      ),
      TransactionModel(
        id: 'tx_03',
        merchant: 'Uber Technologies',
        amount: 290.0,
        category: TransactionCategory.travel,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 1, hours: 3)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_04',
        merchant: 'Amazon India',
        amount: 2450.0,
        category: TransactionCategory.shopping,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(days: 2)),
        type: TransactionType.expense,
        notes: 'Ergonomic desk mat & USB-C hub',
      ),
      TransactionModel(
        id: 'tx_05',
        merchant: 'Zomato Dining',
        amount: 1400.0,
        category: TransactionCategory.food,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
        date: now.subtract(const Duration(days: 3)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_06',
        merchant: 'Blinkit Grocery',
        amount: 980.0,
        category: TransactionCategory.food,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 4)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_07',
        merchant: 'Zara Clothing',
        amount: 2350.0,
        category: TransactionCategory.shopping,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(days: 5)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_08',
        merchant: 'Jio Fiber Broadband',
        amount: 999.0,
        category: TransactionCategory.bills,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
        date: now.subtract(const Duration(days: 6)),
        type: TransactionType.expense,
        isRecurring: true,
      ),
      TransactionModel(
        id: 'tx_09',
        merchant: 'Netflix Subscription',
        amount: 649.0,
        category: TransactionCategory.entertainment,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(days: 7)),
        type: TransactionType.expense,
        isRecurring: true,
      ),
      TransactionModel(
        id: 'tx_10',
        merchant: 'BESCOM Electricity Bill',
        amount: 1601.0,
        category: TransactionCategory.bills,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
        date: now.subtract(const Duration(days: 8)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_11',
        merchant: 'Petrol Shell Fuel',
        amount: 1800.0,
        category: TransactionCategory.travel,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(days: 9)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_12',
        merchant: 'BookMyShow Cinema',
        amount: 950.0,
        category: TransactionCategory.entertainment,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 10)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_13',
        merchant: 'Spotify Premium',
        amount: 119.0,
        category: TransactionCategory.entertainment,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
        date: now.subtract(const Duration(days: 11)),
        type: TransactionType.expense,
        isRecurring: true,
      ),
      TransactionModel(
        id: 'tx_14',
        merchant: 'Apollo Pharmacy',
        amount: 450.0,
        category: TransactionCategory.health,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 12)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_15',
        merchant: 'Metro Smart Card Recharge',
        amount: 500.0,
        category: TransactionCategory.travel,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 14)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_16',
        merchant: 'Dominos Pizza',
        amount: 780.0,
        category: TransactionCategory.food,
        accountId: 'acc_upi_wallet',
        accountName: 'UPI Wallet',
        date: now.subtract(const Duration(days: 15)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_17',
        merchant: 'Miscellaneous / Other',
        amount: 6000.0,
        category: TransactionCategory.other,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
        date: now.subtract(const Duration(days: 16)),
        type: TransactionType.expense,
      ),
      TransactionModel(
        id: 'tx_salary',
        merchant: 'Tech Corp Monthly Payroll',
        amount: 75000.0,
        category: TransactionCategory.salary,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
        date: DateTime(now.year, now.month, 1),
        type: TransactionType.income,
        notes: 'Monthly corporate salary direct deposit',
      ),
      TransactionModel(
        id: 'tx_freelance',
        merchant: 'Client Web Design Gig',
        amount: 12000.0,
        category: TransactionCategory.freelance,
        accountId: 'acc_sbi',
        accountName: 'SBI Savings',
        date: DateTime(now.year, now.month, 10),
        type: TransactionType.income,
        notes: 'Milestone 2 payment',
      ),
    ];

    // 3. Budgets (Matching case study: Monthly Limit ₹30,000, Used ₹23,680 = 78.9%)
    _currentBudget = BudgetModel(
      id: 'budget_2026_09',
      monthYear: '${now.year}-${now.month.toString().padLeft(2, '0')}',
      totalLimit: 30000.0,
      categoryBudgets: [
        const CategoryBudget(
          category: TransactionCategory.food,
          limit: 6000.0,
          spent: 5200.0,
        ),
        const CategoryBudget(
          category: TransactionCategory.shopping,
          limit: 5000.0,
          spent: 4800.0,
        ),
        const CategoryBudget(
          category: TransactionCategory.travel,
          limit: 4000.0,
          spent: 3100.0,
        ),
        const CategoryBudget(
          category: TransactionCategory.bills,
          limit: 7000.0,
          spent: 2600.0,
        ),
        const CategoryBudget(
          category: TransactionCategory.entertainment,
          limit: 3000.0,
          spent: 1980.0,
        ),
        const CategoryBudget(
          category: TransactionCategory.other,
          limit: 5000.0,
          spent: 6000.0,
        ),
      ],
    );

    // 4. Savings Goals (MacBook Pro: ₹72,000 / ₹120,000 = 60%, etc.)
    _savingsGoals = [
      SavingsGoalModel(
        id: 'goal_macbook',
        title: 'MacBook Pro M3 Max',
        targetAmount: 120000.0,
        currentAmount: 72000.0,
        deadline: now.add(const Duration(days: 45)),
        notes: 'Upgrading primary workstation for development',
        createdAt: now.subtract(const Duration(days: 75)),
        colorValue: 0xFF00D4AA,
      ),
      SavingsGoalModel(
        id: 'goal_emergency',
        title: '6-Month Emergency Fund',
        targetAmount: 100000.0,
        currentAmount: 85000.0,
        deadline: now.add(const Duration(days: 120)),
        notes: 'Liquid reserve in high-yield bank deposit',
        createdAt: now.subtract(const Duration(days: 180)),
        colorValue: 0xFF3B82F6,
      ),
      SavingsGoalModel(
        id: 'goal_japan',
        title: 'Tokyo Spring Vacation',
        targetAmount: 200000.0,
        currentAmount: 40000.0,
        deadline: now.add(const Duration(days: 210)),
        notes: 'Flights and accommodation for 2 weeks',
        createdAt: now.subtract(const Duration(days: 30)),
        colorValue: 0xFFFF6B6B,
      ),
    ];

    // 5. Recurring Payments
    _recurringPayments = [
      RecurringPaymentModel(
        id: 'rec_netflix',
        merchant: 'Netflix Premium 4K',
        amount: 649.0,
        frequency: RecurringFrequency.monthly,
        lastPayment: now.subtract(const Duration(days: 27)),
        nextPayment: now.add(const Duration(days: 3)),
        category: TransactionCategory.entertainment,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
      ),
      RecurringPaymentModel(
        id: 'rec_broadband',
        merchant: 'Jio Fiber 300Mbps',
        amount: 999.0,
        frequency: RecurringFrequency.monthly,
        lastPayment: now.subtract(const Duration(days: 22)),
        nextPayment: now.add(const Duration(days: 8)),
        category: TransactionCategory.bills,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
      ),
      RecurringPaymentModel(
        id: 'rec_rent',
        merchant: 'Apartment House Rent',
        amount: 15000.0,
        frequency: RecurringFrequency.monthly,
        lastPayment: now.subtract(const Duration(days: 29)),
        nextPayment: now.add(const Duration(days: 1)),
        category: TransactionCategory.bills,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
      ),
      RecurringPaymentModel(
        id: 'rec_spotify',
        merchant: 'Spotify Individual',
        amount: 119.0,
        frequency: RecurringFrequency.monthly,
        lastPayment: now.subtract(const Duration(days: 14)),
        nextPayment: now.add(const Duration(days: 16)),
        category: TransactionCategory.entertainment,
        accountId: 'acc_icici_cc',
        accountName: 'ICICI Credit Card',
      ),
      RecurringPaymentModel(
        id: 'rec_gym',
        merchant: 'Cult.fit Fitness Membership',
        amount: 1800.0,
        frequency: RecurringFrequency.monthly,
        lastPayment: now.subtract(const Duration(days: 10)),
        nextPayment: now.add(const Duration(days: 20)),
        category: TransactionCategory.health,
        accountId: 'acc_hdfc',
        accountName: 'HDFC Bank',
      ),
    ];
  }
}
