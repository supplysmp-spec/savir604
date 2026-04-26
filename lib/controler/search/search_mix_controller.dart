// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/data/datasource/remote/home/homedata.dart';
class SearchMixController extends GetxController {
  List<ItemsModel> listdata = [];
  late StatusRequest statusRequest;
  HomeData homedata = HomeData(Get.find());
  TextEditingController? search;
  bool isSearch = false;

  @override
  void onInit() {
    search = TextEditingController();
    super.onInit();
  }

  Future<void> searchData() async {
    statusRequest = StatusRequest.loading;
    var response = await homedata.searchData(search!.text);
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        listdata.clear();
        List responsedata = response['data'];
        listdata
            .addAll(responsedata.map((e) => ItemsModel.fromJson(e)).toList());
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  void checkSearch(String val) {
    if (val.isEmpty) {
      statusRequest = StatusRequest.none;
      isSearch = false;
    }
    update();
  }

  void onSearchItems() {
    isSearch = true;
    searchData();
    update();
  }
}
