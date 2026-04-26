// ignore_for_file: unused_local_variable, avoid_print

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class PayPalController extends GetxController {
  String? paymentStatus;
  String? paymentAmount;
  String? userId;
  String? orderId;

  // دالة لفتح الرابط الخاص بـ PayPal

  Future<void> initiatePayment(String amount) async {
    final String paypalLink = 'https://paypal.me/hello353141/$amount';

    // تنفيذ الرابط باستخدام Process في Windows
    if (Platform.isWindows) {
      try {
        await Process.start('cmd', ['/c', 'start', paypalLink]);
      } catch (e) {
        print('Error launching PayPal: $e');
      }
    } else {
      final Uri url = Uri.parse(paypalLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not open PayPal link';
      }
    }
  }

  // دالة لتحديث حالة الدفع بعد إتمام العملية
  void updatePaymentStatus(
      String status, String amount, String userId, String orderId) {
    paymentStatus = status;
    paymentAmount = amount;
    this.userId = userId;
    this.orderId = orderId;
    // قم بإرسال البيانات إلى السيرفر لتحديث قاعدة البيانات
    sendPaymentDataToBackend();
  }

  // إرسال بيانات الدفع إلى الباكند
  Future<void> sendPaymentDataToBackend() async {
    // هنا ترسل البيانات إلى الباكند لتحديث الحالة في قاعدة البيانات
    Map<String, String> paymentData = {
      'payment_status': paymentStatus!,
      'payment_amount': paymentAmount!,
      'user_id': userId!,
      'order_id': orderId!,
    };
    // تنفيذ الطلب HTTP لإرسال البيانات إلى السيرفر
  }
}
