import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:tks/linkapi/linkapi.dart';

Future<void> saveUserToken(int userId) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await http.post(
        Uri.parse("${AppLink.server}/chat/save_token.php"),
        body: {'user_id': userId.toString(), 'fcm_token': token},
      );
      print("✅ تم حفظ التوكن في السيرفر: $token");
    } else {
      print("⚠️ لم يتم الحصول على توكن Firebase");
    }
  } catch (e) {
    print("❌ خطأ أثناء حفظ التوكن: $e");
  }
}
