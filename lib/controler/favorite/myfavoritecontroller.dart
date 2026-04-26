// ignore_for_file: unused_local_variable, avoid_print, unrelated_type_equality_checks

import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/favoritemodel.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tks/controler/favorite/favorite_controler.dart';
import 'package:tks/data/datasource/remote/favorite/myfavorite_data.dart';

class MyFavoriteController extends GetxController {
  MyFavoriteData favoriteData = MyFavoriteData(Get.find());

  List<MyFavoriteModel> data = [];

  late StatusRequest statusRequest;

  MyServices myServices = Get.find();
  final Set<String> deletingIds = <String>{};

//  key => id items
//  Value => 1 OR 0

  Future<void> getData() async {
    data.clear();
    statusRequest = StatusRequest.loading;
    var response = await favoriteData
        .getData(myServices.sharedPreferences.getInt("id")!.toString());
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      // Start backend
      if (response['status'] == "success") {
        List responsedata = response['data'];
        data.addAll(responsedata.map((e) => MyFavoriteModel.fromJson(e)));
        print("data");
        print(data);
      } else {
        statusRequest = StatusRequest.failure;
      }
      // End
    }
    update();
  }

  void _showMessage(String message) {
    final context = Get.context;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);

    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } else {
      debugPrint(message);
    }
  }

  Future<void> deleteFromFavorite(MyFavoriteModel item) async {
    final favoriteId = item.favoriteId?.toString();
    if (favoriteId == null || deletingIds.contains(favoriteId)) {
      return;
    }

    deletingIds.add(favoriteId);
    update();

    final response = await favoriteData.deleteData(favoriteId);
    final requestStatus = handlingData(response);

    if (requestStatus == StatusRequest.success &&
        response['status'] == "success") {
      data.removeWhere((element) => element.favoriteId == item.favoriteId);
      if (Get.isRegistered<FavoriteController>() && item.itemsId != null) {
        Get.find<FavoriteController>().setFavorite(item.itemsId, "0");
      }
      _showMessage("Product removed from favorites");
    } else {
      _showMessage("Unable to remove product from favorites");
    }

    deletingIds.remove(favoriteId);
    update();
  }

  @override
  void onInit() {
    getData();
    super.onInit();
  }
}
