import 'transaction_model.dart';

enum BudgetAlertLevel { normal, warning, strongWarning, exceeded }

class CategoryBudget {
  final TransactionCategory category;
  final double limit;
  final double spent;

  const CategoryBudget({
    required this.category,
    required this.limit,
    this.spent = 0.0,
  });

  double get remaining => (limit - spent).clamp(0, double.infinity);
  double get utilization => limit > 0 ? (spent / limit) : 0.0;
  double get utilizationPercentage => (utilization * 100).clamp(0, 999.0);

  BudgetAlertLevel get alertLevel {
    if (utilization >= 1.0) return BudgetAlertLevel.exceeded;
    if (utilization >= 0.9) return BudgetAlertLevel.strongWarning;
    if (utilization >= 0.8) return BudgetAlertLevel.warning;
    return BudgetAlertLevel.normal;
  }

  CategoryBudget copyWith({
    TransactionCategory? category,
    double? limit,
    double? spent,
  }) {
    return CategoryBudget(
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'limit': limit,
        'spent': spent,
      };

  factory CategoryBudget.fromJson(Map<String, dynamic> json) => CategoryBudget(
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TransactionCategory.other,
        ),
        limit: (json['limit'] as num).toDouble(),
        spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      );
}

class BudgetModel {
  final String id;
  final String monthYear; // e.g. "2026-09"
  final double totalLimit;
  final List<CategoryBudget> categoryBudgets;

  const BudgetModel({
    required this.id,
    required this.monthYear,
    required this.totalLimit,
    required this.categoryBudgets,
  });

  double get totalSpent =>
      categoryBudgets.fold(0.0, (sum, item) => sum + item.spent);

  double get remaining => (totalLimit - totalSpent).clamp(0, double.infinity);

  double get utilization =>
      totalLimit > 0 ? (totalSpent / totalLimit) : 0.0;

  double get utilizationPercentage => (utilization * 100).clamp(0, 999.0);

  BudgetAlertLevel get overallAlertLevel {
    if (utilization >= 1.0) return BudgetAlertLevel.exceeded;
    if (utilization >= 0.9) return BudgetAlertLevel.strongWarning;
    if (utilization >= 0.8) return BudgetAlertLevel.warning;
    return BudgetAlertLevel.normal;
  }

  BudgetModel copyWith({
    String? id,
    String? monthYear,
    double? totalLimit,
    List<CategoryBudget>? categoryBudgets,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      monthYear: monthYear ?? this.monthYear,
      totalLimit: totalLimit ?? this.totalLimit,
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'monthYear': monthYear,
        'totalLimit': totalLimit,
        'categoryBudgets': categoryBudgets.map((e) => e.toJson()).toList(),
      };

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json['id'] as String,
        monthYear: json['monthYear'] as String,
        totalLimit: (json['totalLimit'] as num).toDouble(),
        categoryBudgets: (json['categoryBudgets'] as List<dynamic>? ?? [])
            .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
