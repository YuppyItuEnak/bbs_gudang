import 'package:bbs_gudang/data/models/notification/notification_model.dart';
import 'package:bbs_gudang/data/services/notification/notification_repository.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository = NotificationRepository();

  List<NotificationModel> _listNotifications = [];
  List<NotificationModel> get listNotifications => _listNotifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications({
    required String token,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _listNotifications = await _notificationRepository.fetchNotifications(
        token: token,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
