import 'transaction_model.dart';

enum RecurringFrequency {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.quarterly:
        return 'Quarterly';
      case RecurringFrequency.yearly:
        return 'Yearly';
    }
  }
}

class RecurringPaymentModel {
  final String id;
  final String merchant;
  final double amount;
  final RecurringFrequency frequency;
  final DateTime lastPayment;
  final DateTime nextPayment;
  final TransactionCategory category;
  final bool isActive;
  final String? accountId;
  final String? accountName;

  const RecurringPaymentModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.frequency,
    required this.lastPayment,
    required this.nextPayment,
    required this.category,
    this.isActive = true,
    this.accountId,
    this.accountName,
  });

  int get daysUntilNext =>
      nextPayment.difference(DateTime.now()).inDays.clamp(0, 365);

  RecurringPaymentModel copyWith({
    String? id,
    String? merchant,
    double? amount,
    RecurringFrequency? frequency,
    DateTime? lastPayment,
    DateTime? nextPayment,
    TransactionCategory? category,
    bool? isActive,
    String? accountId,
    String? accountName,
  }) {
    return RecurringPaymentModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      lastPayment: lastPayment ?? this.lastPayment,
      nextPayment: nextPayment ?? this.nextPayment,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'frequency': frequency.name,
        'lastPayment': lastPayment.toIso8601String(),
        'nextPayment': nextPayment.toIso8601String(),
        'category': category.name,
        'isActive': isActive,
        'accountId': accountId,
        'accountName': accountName,
      };

  factory RecurringPaymentModel.fromJson(Map<String, dynamic> json) =>
      RecurringPaymentModel(
        id: json['id'] as String,
        merchant: json['merchant'] as String,
        amount: (json['amount'] as num).toDouble(),
        frequency: RecurringFrequency.values.firstWhere(
          (e) => e.name == json['frequency'],
          orElse: () => RecurringFrequency.monthly,
        ),
        lastPayment: DateTime.tryParse(json['lastPayment'] as String? ?? '') ??
            DateTime.now(),
        nextPayment: DateTime.tryParse(json['nextPayment'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TransactionCategory.other,
        ),
        isActive: json['isActive'] as bool? ?? true,
        accountId: json['accountId'] as String?,
        accountName: json['accountName'] as String?,
      );
}
