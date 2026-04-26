import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/services/services.dart';

class ThemeController extends GetxController {
  ThemeController(this._services);

  final MyServices _services;
  final RxBool isDarkMode = true.obs;

  ThemeMode get themeMode => ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = true;
    _services.sharedPreferences.setBool('isDarkMode', true);
  }

  void toggleTheme() {
    setTheme(true);
  }

  void setTheme(bool isDark) {
    isDarkMode.value = true;
    _services.sharedPreferences.setBool('isDarkMode', true);
    Get.changeThemeMode(ThemeMode.dark);
    update();
  }
}
