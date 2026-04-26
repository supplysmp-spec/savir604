import 'dart:io';
import 'package:tks/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> alertExitApp() {
  Get.defaultDialog(
      title: "تنبيه",
      titleStyle: const TextStyle(
          color: ColorApp.praimaryColor, fontWeight: FontWeight.bold),
      middleText: "هل تريد الخروج من التطبيق",
      actions: [
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(ColorApp.praimaryColor)),
            onPressed: () {
              exit(0);
            },
            child: const Text(
              "تاكيد",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            )),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(ColorApp.praimaryColor)),
            onPressed: () {
              Get.back();
            },
            child: const Text(
              "الغاء",
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
            ))
      ]);
  return Future.value(true);
}
