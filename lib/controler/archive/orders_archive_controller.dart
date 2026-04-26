// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/orders_archive_model.dart';
import 'package:tks/data/datasource/remote/order/orders_archive_data.dart';

class OrdersArchiveControllerr extends GetxController {
  var isLoading = true.obs;
  var ordersList = <OrdersArchiveModel>[].obs;
  var errorMessage = ''.obs;
  late int userId;

  final OrdersArchiveData _ordersData = OrdersArchiveData();

  Future<void> fetchOrdersArchive(int userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final data = await _ordersData.getOrdersArchive(userId);
      ordersList.assignAll(data);
    } catch (e) {
      print("Error loading archive orders: $e");
      errorMessage.value = 'تعذر تحميل أرشيف الطلبات الآن.';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // ✅ اجلب userId من sharedPreferences بدلاً من رقم ثابت
    final myServices = Get.find<MyServices>();
    userId = myServices.sharedPreferences.getInt("id") ?? 0;
    fetchOrdersArchive(userId);
  }
}
