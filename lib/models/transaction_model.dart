import 'package:flutter/material.dart';

enum TransactionType { income, expense, transfer }

enum TransactionCategory {
  food,
  shopping,
  travel,
  bills,
  entertainment,
  health,
  investment,
  salary,
  freelance,
  other;

  String get displayName {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.travel:
        return 'Travel & Transit';
      case TransactionCategory.bills:
        return 'Bills & Utilities';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.health:
        return 'Health & Medical';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.freelance:
        return 'Freelance & Side Gig';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.travel:
        return Icons.directions_car_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_long_rounded;
      case TransactionCategory.entertainment:
        return Icons.movie_filter_rounded;
      case TransactionCategory.health:
        return Icons.medical_services_rounded;
      case TransactionCategory.investment:
        return Icons.trending_up_rounded;
      case TransactionCategory.salary:
        return Icons.account_balance_wallet_rounded;
      case TransactionCategory.freelance:
        return Icons.laptop_mac_rounded;
      case TransactionCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFFF6B6B);
      case TransactionCategory.shopping:
        return const Color(0xFF4ECDC4);
      case TransactionCategory.travel:
        return const Color(0xFFFFBE0B);
      case TransactionCategory.bills:
        return const Color(0xFFFB5607);
      case TransactionCategory.entertainment:
        return const Color(0xFF8338EC);
      case TransactionCategory.health:
        return const Color(0xFF3A86FF);
      case TransactionCategory.investment:
        return const Color(0xFF00D4AA);
      case TransactionCategory.salary:
        return const Color(0xFF10B981);
      case TransactionCategory.freelance:
        return const Color(0xFF06D6A0);
      case TransactionCategory.other:
        return const Color(0xFF94A3B8);
    }
  }
}

enum TransactionStatus { completed, pending, failed }

class TransactionModel {
  final String id;
  final String merchant;
  final double amount;
  final TransactionCategory category;
  final String accountId;
  final String? accountName;
  final DateTime date;
  final TransactionType type;
  final TransactionStatus status;
  final String? notes;
  final bool isRecurring;

  const TransactionModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.accountId,
    this.accountName,
    required this.date,
    required this.type,
    this.status = TransactionStatus.completed,
    this.notes,
    this.isRecurring = false,
  });

  TransactionModel copyWith({
    String? id,
    String? merchant,
    double? amount,
    TransactionCategory? category,
    String? accountId,
    String? accountName,
    DateTime? date,
    TransactionType? type,
    TransactionStatus? status,
    String? notes,
    bool? isRecurring,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'category': category.name,
        'accountId': accountId,
        'accountName': accountName,
        'date': date.toIso8601String(),
        'type': type.name,
        'status': status.name,
        'notes': notes,
        'isRecurring': isRecurring,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        merchant: json['merchant'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TransactionCategory.other,
        ),
        accountId: json['accountId'] as String,
        accountName: json['accountName'] as String?,
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
        type: TransactionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TransactionType.expense,
        ),
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.completed,
        ),
        notes: json['notes'] as String?,
        isRecurring: json['isRecurring'] as bool? ?? false,
      );
}
