import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/services/services.dart';

class LocaleController extends GetxController {
  late Locale language; // غير قابل لأن يكون null
  MyServices myServices = Get.find();

  void changeLang(String codelang) {
    language = Locale(codelang);
    Get.updateLocale(language);
    myServices.sharedPreferences.setString("lang", codelang);
    update();
  }

  @override
  void onInit() {
    String? lang = myServices.sharedPreferences.getString("lang");

    if (lang == "ar") {
      language = const Locale("ar");
    } else if (lang == "en") {
      language = const Locale("en");
    } else {
      language = Locale(Get.deviceLocale?.languageCode ?? "en");
    }

    super.onInit();
  }
}
