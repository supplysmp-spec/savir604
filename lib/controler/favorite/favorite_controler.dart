// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/favorite/myfavoritecontroller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/favorite/favorite_data.dart';

class FavoriteController extends GetxController {
  static const String _favoritesStorageKey = 'favorite_item_ids';

  final FavoriteData favoriteData = FavoriteData(Get.find());
  final MyServices myServices = Get.find();

  List data = [];
  late StatusRequest statusRequest;
  Map isFavorite = {};

  @override
  void onInit() {
    super.onInit();
    _loadPersistedFavorites();
  }

  void initializeFavoriteIfNeeded(String id, String? fallbackValue) {
    if (isFavorite[id] != null) return;
    isFavorite[id] = _persistedFavoriteIds.contains(id)
        ? '1'
        : (fallbackValue ?? '0');
  }

  final Set<String> _persistedFavoriteIds = <String>{};

  void _loadPersistedFavorites() {
    final stored =
        myServices.sharedPreferences.getStringList(_favoritesStorageKey) ?? [];
    _persistedFavoriteIds
      ..clear()
      ..addAll(stored);
    for (final id in _persistedFavoriteIds) {
      isFavorite[id] = '1';
    }
  }

  Future<void> _persistFavorites() async {
    await myServices.sharedPreferences.setStringList(
      _favoritesStorageKey,
      _persistedFavoriteIds.toList(),
    );
  }

  void setFavorite(id, val) {
    isFavorite[id] = val;
    final itemId = '$id';
    if ('$val' == '1') {
      _persistedFavoriteIds.add(itemId);
    } else {
      _persistedFavoriteIds.remove(itemId);
    }
    _persistFavorites();
    update();
  }

  void _showMessage(String message) {
    final context = Get.context;
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);

    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      debugPrint(message);
    }
  }

  Future<void> addFavorite(String itemsid) async {
    data.clear();
    statusRequest = StatusRequest.loading;
    final response = await favoriteData.addFavorite(
      myServices.sharedPreferences.getInt("id")!.toString(),
      itemsid,
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        _showMessage("add_favorite_success".tr);
        if (Get.isRegistered<MyFavoriteController>()) {
          await Get.find<MyFavoriteController>().getData();
        }
      } else {
        statusRequest = StatusRequest.failure;
        _showMessage("unable_add_favorite".tr);
      }
    }
  }

  Future<void> removeFavorite(String itemsid) async {
    data.clear();
    statusRequest = StatusRequest.loading;
    final response = await favoriteData.removeFavorite(
      myServices.sharedPreferences.getInt("id")!.toString(),
      itemsid,
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        _showMessage("remove_favorite_success".tr);
        if (Get.isRegistered<MyFavoriteController>()) {
          await Get.find<MyFavoriteController>().getData();
        }
      } else {
        statusRequest = StatusRequest.failure;
        _showMessage("unable_remove_favorite".tr);
      }
    }
  }
}
