// ignore_for_file: avoid_print

import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/data/datasource/model/cartmodel.dart';
import 'package:tks/data/datasource/model/ordersmodel.dart';
import 'package:tks/data/datasource/remote/orders/details_data.dart';

class OrdersDetailsController extends GetxController {
  OrdersDetailsData ordersDetailsData = OrdersDetailsData(Get.find());

  List<CartModel> data = [];
  late StatusRequest statusRequest;
  late OrdersModel ordersModel;

  void initializeData() {
    // يتم استخدام هذا الدالة لإعداد البيانات بدون أي خريطة
  }

  @override
  void onInit() {
    ordersModel = Get.arguments['ordersmodel'];
    initializeData();
    getData();
    super.onInit();
  }

  getData() async {
    statusRequest = StatusRequest.loading;
    data.clear();

    var response = await ordersDetailsData.getData(ordersModel.ordersId!);

    print("=============================== Controller $response ");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        if (response['order'] is Map) {
          ordersModel =
              OrdersModel.fromJson(Map<String, dynamic>.from(response['order']));
        }
        List listdata = response['items'] ?? [];
        data.addAll(listdata.map((e) => CartModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
