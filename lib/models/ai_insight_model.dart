import 'package:flutter/material.dart';
import 'transaction_model.dart';

enum InsightType {
  categorySpike,
  budgetRisk,
  savingsMilestone,
  unusualTransaction,
  recurringReminder,
  positiveTrend;

  IconData get icon {
    switch (this) {
      case InsightType.categorySpike:
        return Icons.trending_up_rounded;
      case InsightType.budgetRisk:
        return Icons.warning_amber_rounded;
      case InsightType.savingsMilestone:
        return Icons.emoji_events_rounded;
      case InsightType.unusualTransaction:
        return Icons.notification_important_rounded;
      case InsightType.recurringReminder:
        return Icons.repeat_rounded;
      case InsightType.positiveTrend:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get color {
    switch (this) {
      case InsightType.categorySpike:
        return const Color(0xFFFF6B6B);
      case InsightType.budgetRisk:
        return const Color(0xFFF59E0B);
      case InsightType.savingsMilestone:
        return const Color(0xFF00D4AA);
      case InsightType.unusualTransaction:
        return const Color(0xFFFB5607);
      case InsightType.recurringReminder:
        return const Color(0xFF3A86FF);
      case InsightType.positiveTrend:
        return const Color(0xFF10B981);
    }
  }
}

class AiInsightModel {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final String recommendation;
  final TransactionCategory? category;
  final double? impactAmount;
  final double confidenceScore;
  final DateTime createdAt;
  final bool isDismissed;

  const AiInsightModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.recommendation,
    this.category,
    this.impactAmount,
    this.confidenceScore = 0.85,
    required this.createdAt,
    this.isDismissed = false,
  });

  AiInsightModel copyWith({
    String? id,
    InsightType? type,
    String? title,
    String? description,
    String? recommendation,
    TransactionCategory? category,
    double? impactAmount,
    double? confidenceScore,
    DateTime? createdAt,
    bool? isDismissed,
  }) {
    return AiInsightModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      recommendation: recommendation ?? this.recommendation,
      category: category ?? this.category,
      impactAmount: impactAmount ?? this.impactAmount,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      createdAt: createdAt ?? this.createdAt,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'description': description,
        'recommendation': recommendation,
        'category': category?.name,
        'impactAmount': impactAmount,
        'confidenceScore': confidenceScore,
        'createdAt': createdAt.toIso8601String(),
        'isDismissed': isDismissed,
      };

  factory AiInsightModel.fromJson(Map<String, dynamic> json) => AiInsightModel(
        id: json['id'] as String,
        type: InsightType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => InsightType.positiveTrend,
        ),
        title: json['title'] as String,
        description: json['description'] as String,
        recommendation: json['recommendation'] as String,
        category: json['category'] != null
            ? TransactionCategory.values.firstWhere(
                (e) => e.name == json['category'],
                orElse: () => TransactionCategory.other,
              )
            : null,
        impactAmount: (json['impactAmount'] as num?)?.toDouble(),
        confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.85,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        isDismissed: json['isDismissed'] as bool? ?? false,
      );
}
