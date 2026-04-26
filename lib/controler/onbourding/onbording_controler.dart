import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/static/static.dart';

abstract class OnBoardingController extends GetxController {
  void next();
  void skip();
  void onPageChanged(int index);
}

class OnBordingControlerImp extends OnBoardingController {
  late PageController pageController;
  int currentPage = 0;
  final MyServices myServices = Get.find();

  void _finish() {
    myServices.sharedPreferences.setString('step', '1');
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void next() {
    currentPage++;

    if (currentPage > onbordinglist.length - 1) {
      _finish();
    } else {
      pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      update();
    }
  }

  @override
  void skip() {
    _finish();
  }

  @override
  void onPageChanged(int index) {
    currentPage = index;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }
}
