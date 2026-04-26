// ignore_for_file: unused_local_variable

import 'package:http/http.dart' as http;
import 'dart:convert';

class PayPalData {
  static Future<void> savePaymentData(String paymentStatus,
      String paymentAmount, String userId, String orderId) async {
    final response = await http.post(
      Uri.parse(
          'https://f023-197-54-246-240.ngrok-free.app/savir603/zahra/save_payment.php'),
      body: {
        'payment_status': paymentStatus,
        'payment_amount': paymentAmount,
        'user_id': userId,
        'order_id': orderId,
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      // التعامل مع البيانات المستلمة من السيرفر
    } else {
      // التعامل مع الأخطاء
    }
  }
}
