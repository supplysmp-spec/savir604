// ignore_for_file: unused_import, camel_case_types

import 'package:tks/controler/onbourding/onbording_controler.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/data/static/static.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class slideronbording extends GetView<OnBordingControlerImp> {
  const slideronbording({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: controller.pageController,
        onPageChanged: (val) {
          controller.onPageChanged(val);
        },
        itemCount: onbordinglist.length,
        itemBuilder: (context, i) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(onbordinglist[i].title!,
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(
                  height: 30,
                ),
                Image.asset(
                  onbordinglist[i].images!,
                  width: 250,
                  height: 250,
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(onbordinglist[i].body!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge),
                )
              ],
            ));
  }
}
