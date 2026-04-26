// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/address/address_data.dart';

class AddAddressDetailsController extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;

  final AddressData addressData = AddressData(Get.find());
  final MyServices myServices = Get.find();

  final TextEditingController name = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController street = TextEditingController();
  final TextEditingController phone = TextEditingController();

  void initializeData() {
    print("Initializing address details.");
  }

  Future<void> addAddress() async {
    statusRequest = StatusRequest.loading;
    update();

    if (name.text.isEmpty ||
        city.text.isEmpty ||
        street.text.isEmpty ||
        phone.text.isEmpty) {
      Get.snackbar(
        'Missing fields',
        'Please complete all address fields.',
      );
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    final String userId =
        myServices.sharedPreferences.getInt("id")?.toString() ?? '';
    if (userId.isEmpty) {
      Get.snackbar(
        'Login required',
        'Please login again before saving the address.',
      );
      statusRequest = StatusRequest.failure;
      update();
      return;
    }

    final dynamic response = await addressData.addData(
      userId,
      name.text,
      city.text,
      street.text,
      phone.text,
    );

    print("=============================== Controller $response ");

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Could not save',
          'Something went wrong while saving this address.',
        );
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    initializeData();
    super.onInit();
  }
}
