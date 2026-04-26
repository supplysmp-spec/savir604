import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tks/core/services/services.dart';
import 'package:tks/linkapi/linkapi.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String refType;
  final String refId;
  final String createdAt;
  final bool isRead;
  final Map<String, dynamic> payload;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.refType,
    required this.refId,
    required this.createdAt,
    required this.isRead,
    required this.payload,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> payloadMap = {};
    final rawPayload = json['notification_payload'];
    if (rawPayload is String && rawPayload.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPayload);
        if (decoded is Map<String, dynamic>) {
          payloadMap = decoded;
        }
      } catch (_) {}
    } else if (rawPayload is Map<String, dynamic>) {
      payloadMap = rawPayload;
    }

    return AppNotificationItem(
      id: json['notification_id']?.toString() ?? '',
      title: json['notification_title']?.toString() ?? '',
      body: json['notification_body']?.toString() ?? '',
      type: json['notification_type']?.toString() ?? 'general',
      refType: json['notification_ref_type']?.toString() ?? '',
      refId: json['notification_ref_id']?.toString() ?? '',
      createdAt: json['notification_created_at']?.toString() ?? '',
      isRead: json['notification_is_read']?.toString() == '1',
      payload: payloadMap,
    );
  }
}

class NotificationController extends GetxController {
  final MyServices _services = Get.find();
  Timer? _pollingTimer;
  static const Set<String> _adminNotificationTypes = <String>{
    'admin_chat',
    'order_status',
    'payment_status',
    'new_product',
  };

  final notifications = <AppNotificationItem>[].obs;
  final isLoading = false.obs;

  int get notificationCount => notifications.length;
  int get unreadCount => notifications.where((item) => !item.isRead).length;

  int get currentUserId => _services.sharedPreferences.getInt('id') ?? 0;

  Future<void> fetchNotifications() async {
    if (isLoading.value) {
      return;
    }

    if (currentUserId <= 0) {
      notifications.clear();
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(AppLink.notification),
        body: {'id': currentUserId.toString()},
      );

      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['status'] == 'success') {
        final list = (decoded['data'] as List? ?? [])
            .map((e) => AppNotificationItem.fromJson(Map<String, dynamic>.from(e)))
            .where((AppNotificationItem item) => _isAdminNotificationType(item.type))
            .toList();
        notifications.assignAll(list);
      }
    } catch (_) {
      // Keep existing list if fetch fails.
    } finally {
      isLoading.value = false;
    }
  }

  void addForegroundNotification({
    required String title,
    required String body,
    String id = '',
    String type = 'general',
    String refType = '',
    String refId = '',
    Map<String, dynamic> payload = const {},
  }) {
    if (!_isAdminNotificationType(type)) {
      return;
    }

    final item = AppNotificationItem(
      id: id.isNotEmpty ? id : 'local_${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      refType: refType,
      refId: refId,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
      payload: payload,
    );

    final existingIndex = notifications.indexWhere((element) => element.id == item.id);
    if (existingIndex >= 0) {
      notifications[existingIndex] = item;
      return;
    }

    notifications.insert(0, item);
  }

  Future<void> markAsRead(String notificationId) async {
    if (currentUserId <= 0 || notificationId.trim().isEmpty) {
      return;
    }

    final index = notifications.indexWhere((item) => item.id == notificationId);
    if (index < 0 || notifications[index].isRead) {
      return;
    }

    final current = notifications[index];
    notifications[index] = AppNotificationItem(
      id: current.id,
      title: current.title,
      body: current.body,
      type: current.type,
      refType: current.refType,
      refId: current.refId,
      createdAt: current.createdAt,
      isRead: true,
      payload: current.payload,
    );

    try {
      await http.post(
        Uri.parse(AppLink.notificationMarkRead),
        body: {
          'user_id': currentUserId.toString(),
          'notification_id': notificationId,
        },
      );
    } catch (_) {
      // Keep UI responsive even if the request fails.
    }
  }

  Future<void> markAllAsRead() async {
    if (currentUserId <= 0 || notifications.isEmpty) {
      return;
    }

    notifications.assignAll(
      notifications
          .map(
            (item) => AppNotificationItem(
              id: item.id,
              title: item.title,
              body: item.body,
              type: item.type,
              refType: item.refType,
              refId: item.refId,
              createdAt: item.createdAt,
              isRead: true,
              payload: item.payload,
            ),
          )
          .toList(),
    );

    try {
      await http.post(
        Uri.parse(AppLink.notificationMarkAllRead),
        body: {
          'user_id': currentUserId.toString(),
        },
      );
    } catch (_) {
      // Keep UI responsive even if the request fails.
    }
  }

  void clearNotifications() {
    notifications.clear();
  }

  bool _isAdminNotificationType(String type) {
    return _adminNotificationTypes.contains(type.trim());
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    if (currentUserId <= 0) {
      return;
    }

    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchNotifications();
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _startPolling();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
