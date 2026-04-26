// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> saveUserToken(int userId) async {
  try {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      print("🔥 Saving FCM Token for user $userId: $token");

      await http.post(
        Uri.parse('https://savir-technology.online/Precious/chat/save_token.php'),
        body: {
          'user_id': userId.toString(),
          'fcm_token': token,
        },
      );
    }

    messaging.onTokenRefresh.listen((newToken) async {
      print("🔁 Token refreshed for user $userId: $newToken");
      await http.post(
        Uri.parse('https://savir-technology.online/Precious/chat/save_token.php'),
        body: {
          'user_id': userId.toString(),
          'fcm_token': newToken,
        },
      );
    });
  } catch (e) {
    print("⚠️ Error saving token: $e");
  }
}
