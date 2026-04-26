// ignore_for_file: prefer_const_constructors

import 'package:tks/controler/onbourding/onbording_controler.dart';
import 'package:tks/core/constant/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Custtombottononbording extends GetView<OnBordingControlerImp> {
  const Custtombottononbording({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 70),
      child: MaterialButton(
        textColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
        onPressed: () {
          controller.next();
        },
        color: ColorApp.praimaryColor,
        child: Text(
          "8".tr,
          style: TextStyle(fontFamily: "myfont"),
        ),
      ),
    );
  }
}
