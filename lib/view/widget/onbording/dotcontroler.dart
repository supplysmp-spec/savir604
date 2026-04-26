// ignore_for_file: camel_case_types, non_constant_identifier_names

import 'package:tks/controler/onbourding/onbording_controler.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/data/static/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class customdotcontroleronbording extends StatelessWidget {
  const customdotcontroleronbording({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBordingControlerImp>(
      builder: (controller) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            onbordinglist.length,
            (Index) => AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              margin: const EdgeInsets.only(right: 5),
              width: controller.currentPage == Index ? 15 : 5,
              height: 6,
              decoration: BoxDecoration(
                color: ColorApp.praimaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
