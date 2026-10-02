import 'dart:async';
import '../models/notification_model.dart';
import '../models/budget_model.dart';
import '../models/recurring_payment_model.dart';
import '../core/utils/currency_formatter.dart';

class NotificationService {
  final List<NotificationModel> _notifications = [];
  final _controller = StreamController<List<NotificationModel>>.broadcast();

  Stream<List<NotificationModel>> get notificationStream => _controller.stream;
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  NotificationService() {
    _seedDefaultNotifications();
  }

  void _seedDefaultNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: 'notif_1',
        title: 'Budget Alert: Food & Dining',
        body:
            'You have spent 86.7% of your Food & Dining budget (₹5,200 / ₹6,000).',
        type: NotificationType.budgetAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        actionRoute: '/main/dashboard',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Upcoming Bill: Netflix',
        body: '₹649 will be auto-debited in 3 days from your HDFC Salary Account.',
        type: NotificationType.recurringReminder,
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        actionRoute: '/main/dashboard',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Goal Progress: MacBook Pro',
        body: 'You are at 60% of your target! Only ₹48,000 remaining.',
        type: NotificationType.goalProgress,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        actionRoute: '/main/savings',
      ),
      NotificationModel(
        id: 'notif_4',
        title: 'Security Notice',
        body: 'Biometric authentication was successfully enabled for this device.',
        type: NotificationType.securityNotice,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        actionRoute: '/main/profile',
      ),
    ]);
    _notify();
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _notify();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notify();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notify();
  }

  void clearAll() {
    _notifications.clear();
    _notify();
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Check budget thresholds and dispatch notification if crossed
  void checkBudgetAlerts(BudgetModel budget) {
    for (final cb in budget.categoryBudgets) {
      if (cb.alertLevel == BudgetAlertLevel.strongWarning ||
          cb.alertLevel == BudgetAlertLevel.exceeded) {
        final alertId = 'alert_${budget.monthYear}_${cb.category.name}';
        if (!_notifications.any((n) => n.id == alertId)) {
          addNotification(
            NotificationModel(
              id: alertId,
              title: 'Budget Warning: ${cb.category.displayName}',
              body:
                  '${cb.category.displayName} is at ${cb.utilizationPercentage.toStringAsFixed(0)}% utilization (${CurrencyFormatter.formatINR(cb.spent)} / ${CurrencyFormatter.formatINR(cb.limit)}).',
              type: NotificationType.budgetAlert,
              timestamp: DateTime.now(),
              actionRoute: '/main/dashboard',
            ),
          );
        }
      }
    }
  }

  /// Check upcoming recurring payments (within 3 days)
  void checkRecurringReminders(List<RecurringPaymentModel> recurring) {
    for (final r in recurring) {
      if (r.daysUntilNext <= 3 && r.isActive) {
        final reminderId = 'rem_${r.id}_${r.nextPayment.day}';
        if (!_notifications.any((n) => n.id == reminderId)) {
          addNotification(
            NotificationModel(
              id: reminderId,
              title: 'Upcoming Payment: ${r.merchant}',
              body:
                  '${CurrencyFormatter.formatINR(r.amount)} is scheduled for ${r.nextPayment.day}/${r.nextPayment.month}.',
              type: NotificationType.recurringReminder,
              timestamp: DateTime.now(),
              actionRoute: '/main/dashboard',
            ),
          );
        }
      }
    }
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_notifications));
    }
  }

  void dispose() {
    _controller.close();
  }
}
