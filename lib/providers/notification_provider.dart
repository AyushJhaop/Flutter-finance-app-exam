import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  StreamSubscription? _sub;

  NotificationProvider({required NotificationService service})
      : _service = service { // ignore: prefer_initializing_formals
    _sub = _service.notificationStream.listen((_) {
      notifyListeners();
    });
  }

  List<NotificationModel> get notifications => _service.notifications;
  int get unreadCount => _service.unreadCount;

  void markAsRead(String id) => _service.markAsRead(id);
  void markAllAsRead() => _service.markAllAsRead();
  void clearAll() => _service.clearAll();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
