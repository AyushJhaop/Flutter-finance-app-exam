import 'package:flutter/material.dart';

enum NotificationType {
  budgetAlert,
  recurringReminder,
  goalProgress,
  securityNotice,
  reportReady;

  IconData get icon {
    switch (this) {
      case NotificationType.budgetAlert:
        return Icons.warning_rounded;
      case NotificationType.recurringReminder:
        return Icons.calendar_month_rounded;
      case NotificationType.goalProgress:
        return Icons.stars_rounded;
      case NotificationType.securityNotice:
        return Icons.shield_rounded;
      case NotificationType.reportReady:
        return Icons.description_rounded;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.budgetAlert:
        return const Color(0xFFEF4444);
      case NotificationType.recurringReminder:
        return const Color(0xFF3B82F6);
      case NotificationType.goalProgress:
        return const Color(0xFF00D4AA);
      case NotificationType.securityNotice:
        return const Color(0xFFF59E0B);
      case NotificationType.reportReady:
        return const Color(0xFF8B5CF6);
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
        'actionRoute': actionRoute,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        type: NotificationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => NotificationType.budgetAlert,
        ),
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
            DateTime.now(),
        isRead: json['isRead'] as bool? ?? false,
        actionRoute: json['actionRoute'] as String?,
      );
}
