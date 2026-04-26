import 'package:tks/controler/home/home_controller.dart';
import 'package:tks/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCardHome extends GetView<HomeControllerImp> {
  final String title;
  final String body;
  const CustomCardHome({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            height: 100,
            decoration: BoxDecoration(
              color: ColorApp.praimaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
              subtitle: Text(body,
                  style: const TextStyle(color: Colors.white, fontSize: 30)),
            ),
          ),
          Positioned(
            top: -20,
            right: controller.lang == "en" ? -20 : null,
            left: controller.lang == "ar" ? -20 : null,
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: ColorApp.secoundColor,
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
