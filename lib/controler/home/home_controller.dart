// ignore_for_file: overridden_fields, avoid_print

import 'package:flutter/widgets.dart';
import 'package:tks/controler/search/search_mix_controller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:get/get.dart';
import 'package:tks/data/datasource/remote/home/homedata.dart';

abstract class HomeController extends SearchMixController {
  initialData();
  getdata();
  goToItems(List categories, int selectedCat, String categoryid);
}

class HomeControllerImp extends HomeController {
  MyServices myServices = Get.find();

  String? username;
  String? id;
  String? lang;

  @override
  HomeData homedata = HomeData(Get.find());

  List categories = [];
  List items = [];
  List<ItemsModel> searchResults = []; // This holds the search results

  @override
  initialData() {
    lang = myServices.sharedPreferences.getString("lang");
    username = myServices.sharedPreferences.getString("username");
    id = myServices.sharedPreferences.getInt("id")?.toString();
  }

  @override
  void onInit() {
    search = TextEditingController();
    getdata();
    initialData();
    super.onInit();
  }

  @override
  getdata() async {
    statusRequest = StatusRequest.loading;
    var response = await homedata.getData();
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        categories.addAll(response['categories']['data']);
        items.addAll(response['items']['data']);
        if (items.isEmpty) {
          var fallbackResponse = await homedata.searchData("");
          var fallbackStatus = handlingData(fallbackResponse);
          if (StatusRequest.success == fallbackStatus &&
              fallbackResponse['status'] == "success") {
            items.addAll(fallbackResponse['data']);
          }
        }
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  void syncProductRating(ItemsModel updatedItem) {
    for (var i = 0; i < items.length; i++) {
      final item = ItemsModel.fromJson(Map<String, dynamic>.from(items[i]));
      if (item.itemsId == updatedItem.itemsId) {
        final updatedMap = Map<String, dynamic>.from(items[i]);
        updatedMap['average_rating'] = updatedItem.averageRating;
        updatedMap['ratings_count'] = updatedItem.ratingsCount;
        updatedMap['rating_percentage'] = updatedItem.ratingPercentage;
        updatedMap['is_top_rated'] = updatedItem.isTopRated;
        items[i] = updatedMap;
        break;
      }
    }

    for (var i = 0; i < searchResults.length; i++) {
      if (searchResults[i].itemsId == updatedItem.itemsId) {
        searchResults[i].averageRating = updatedItem.averageRating;
        searchResults[i].ratingsCount = updatedItem.ratingsCount;
        searchResults[i].ratingPercentage = updatedItem.ratingPercentage;
        searchResults[i].isTopRated = updatedItem.isTopRated;
        break;
      }
    }
    update();
  }

  @override
  goToItems(categories, selectedCat, categoryid) {
    Get.toNamed(AppRoutes.items, arguments: {
      "categories": categories,
      "selectedcat": selectedCat,
      "catid": categoryid
    });
  }

  goToPageProductDetails(itemsModel) {
    Get.toNamed("productdetails", arguments: {"itemsmodel": itemsModel});
  }

  @override
  searchData() async {
    statusRequest = StatusRequest.loading;
    var response = await homedata.searchData(search!.text);
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        searchResults.clear();
        List responsedata = response['data'];
        searchResults.addAll(responsedata.map((e) => ItemsModel.fromJson(e)));
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  bool isSearch = false;

  @override
  checkSearch(val) {
    if (val == "") {
      statusRequest = StatusRequest.none;
      isSearch = false;
    } else {
      isSearch = true;
    }
    update();
  }

  @override
  onSearchItems() {
    isSearch = true;
    searchData();
    update();
  }
}
