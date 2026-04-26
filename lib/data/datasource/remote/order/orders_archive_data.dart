// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:tks/data/datasource/model/orders_archive_model.dart';
import 'package:tks/linkapi/linkapi.dart';

import 'dart:convert';

class OrdersArchiveData {
  /// 📦 دالة جلب أرشيف الطلبات من السيرفر
  Future<List<OrdersArchiveModel>> getOrdersArchive(int userId) async {
    try {
      var response = await http.post(
        Uri.parse(AppLink.ordersarchive),
        body: {'userid': userId.toString()}, // ← بدل user_id إلى userid
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          List orders = data['data'];
          return orders.map((e) => OrdersArchiveModel.fromJson(e)).toList();
        } else {
          print("⚠️ لا يوجد بيانات أرشيف للمستخدم $userId");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error in getOrdersArchive: $e");
    }
    return [];
  }
}
