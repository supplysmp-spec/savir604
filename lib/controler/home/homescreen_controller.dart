import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/view/screen/admin_chats_screen.dart';
import 'package:tks/view/screen/cart.dart';
import 'package:tks/view/screen/fragrance/fragrance_builder_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_community_screen.dart';
import 'package:tks/view/screen/home.dart';

abstract class HomeScreenController extends GetxController {
  changePage(int currentpage);
}

class HomeScreenControllerImp extends HomeScreenController {
  int currentpage = 0;
  late int userId;
  late List<Widget> listPage;

  final MyServices myServices = Get.find();

  @override
  void onInit() {
    super.onInit();
    userId = myServices.sharedPreferences.getInt('id') ?? 0;
    listPage = <Widget>[
      const HomePage(),
      const FragranceCommunityScreen(),
      const FragranceBuilderScreen(),
      SupportHome(userId: userId),
      Cart(),
    ];
  }

  @override
  changePage(int i) {
    currentpage = i;
    update();
  }

  final List<Map<String, dynamic>> bottomappbar = <Map<String, dynamic>>[
    <String, dynamic>{'title': 'Home', 'icon': Icons.home_outlined},
    <String, dynamic>{'title': 'Community', 'icon': Icons.groups_2_outlined},
    <String, dynamic>{'title': 'Builder', 'icon': Icons.auto_awesome_outlined},
    <String, dynamic>{
      'title': 'Chat',
      'icon': Icons.chat_bubble_outline_rounded,
    },
    <String, dynamic>{'title': 'Cart', 'icon': Icons.shopping_bag_outlined},
  ];
}
