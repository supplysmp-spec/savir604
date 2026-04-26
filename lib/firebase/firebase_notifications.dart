// ignore_for_file: avoid_print

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:tks/controler/notification_con.dart';
import 'package:tks/core/functions/notification_navigation.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/linkapi/linkapi.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
    'Background notification: ${message.notification?.title} - ${message.notification?.body}',
  );
}

class FirebaseMessagingService {
  static const String _channelId = 'snapchat_sound_notifications_v2';
  static const String _channelName = 'Snapchat Sound Notifications';
  static const String _channelDescription =
      'Used for instant app notifications with sound.';
  static const String _androidSound = 'snapchat_notification_sound';
  static const Set<String> _adminNotificationTypes = <String>{
    'admin_chat',
    'order_status',
    'payment_status',
    'new_product',
  };

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(_androidSound),
  );

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initFirebaseMessaging() async {
    await _initializeLocalNotifications();

    final NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('FCM authorization: ${settings.authorizationStatus}');

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    print('Firebase Token: $token');
    await _syncTokenWithServer(token);

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('Firebase token refreshed: $newToken');
      await _syncTokenWithServer(newToken);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = _readMessageTitle(message);
      final body = _readMessageBody(message);
      final type = message.data['type']?.toString() ?? 'general';

      if (!_isAdminNotificationType(type)) {
        return;
      }

      final controller = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());

      controller.addForegroundNotification(
        id: message.data['notification_id']?.toString() ?? '',
        title: title,
        body: body,
        type: type,
        refType: message.data['ref_type']?.toString() ?? '',
        refId: message.data['ref_id']?.toString() ?? '',
        payload: Map<String, dynamic>.from(message.data),
      );

      await _showForegroundNotification(message, title: title, body: body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = _decodePayload(response.payload);
        NotificationNavigation.openFromData(
          payload: payload,
          type: payload['type']?.toString(),
          refType: payload['ref_type']?.toString(),
          refId: payload['ref_id']?.toString(),
        );
      },
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _showForegroundNotification(
    RemoteMessage message, {
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound(_androidSound),
      ticker: 'ticker',
      icon: 'ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      _notificationId(message),
      title,
      body,
      details,
      payload: _encodePayload(message.data),
    );
  }

  static int _notificationId(RemoteMessage message) {
    final rawId = message.data['notification_id']?.toString();
    final parsed = rawId == null ? null : int.tryParse(rawId);
    return parsed ?? DateTime.now().millisecondsSinceEpoch.remainder(1000000);
  }

  static String _readMessageTitle(RemoteMessage message) {
    return message.notification?.title ??
        message.data['title']?.toString() ??
        message.data['notification_title']?.toString() ??
        'New notification';
  }

  static String _readMessageBody(RemoteMessage message) {
    return message.notification?.body ??
        message.data['body']?.toString() ??
        message.data['notification_body']?.toString() ??
        '';
  }

  static String _encodePayload(Map<String, dynamic> data) {
    return data.entries
        .map((entry) => '${Uri.encodeComponent(entry.key)}='
            '${Uri.encodeComponent('${entry.value}')}')
        .join('&');
  }

  static Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final result = <String, dynamic>{};
    for (final part in payload.split('&')) {
      if (part.isEmpty || !part.contains('=')) {
        continue;
      }

      final pieces = part.split('=');
      final key = Uri.decodeComponent(pieces.first);
      final value = Uri.decodeComponent(pieces.skip(1).join('='));
      result[key] = value;
    }
    return result;
  }

  void _handleNotificationOpen(RemoteMessage message) {
    final String? type = message.data['type']?.toString();
    if (!_isAdminNotificationType(type ?? 'general')) {
      return;
    }

    NotificationNavigation.openFromData(
      payload: Map<String, dynamic>.from(message.data),
      type: type,
      refType: message.data['ref_type']?.toString(),
      refId: message.data['ref_id']?.toString(),
    );
  }

  static bool _isAdminNotificationType(String type) {
    return _adminNotificationTypes.contains(type.trim());
  }

  Future<void> _syncTokenWithServer(String? token) async {
    if (token == null || token.trim().isEmpty) {
      return;
    }

    final services = Get.find<MyServices>();
    final currentUserId = services.sharedPreferences.getInt('id') ?? 0;
    if (currentUserId <= 0) {
      return;
    }

    try {
      await GetConnect().post(
        '${AppLink.server}/chat/save_token.php',
        {
          'user_id': currentUserId.toString(),
          'fcm_token': token,
        },
      );
    } catch (_) {
      // Ignore sync failures and retry later.
    }
  }
}
