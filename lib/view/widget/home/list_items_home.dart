// ignore_for_file: deprecated_member_use

import 'package:tks/controler/home/home_controller.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/view/widget/common/product_card_image_slider.dart';

class ListItemsHome extends GetView<HomeControllerImp> {
  const ListItemsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        itemCount: controller.items.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          return ItemsHome(
            itemsModel: ItemsModel.fromJson(controller.items[i]),
          );
        },
      ),
    );
  }
}

class ItemsHome extends StatelessWidget {
  final ItemsModel itemsModel;
  const ItemsHome({super.key, required this.itemsModel});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeControllerImp>(); // احضار المتحكم

    return InkWell(
      onTap: () {
        controller.goToPageProductDetails(
            itemsModel); // توجيه المستخدم إلى صفحة تفاصيل المنتج
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 150,
            height: 100,
            child: ProductCardImageSlider(
              imagePaths: itemsModel.galleryImagePaths,
              label: itemsModel.itemsNameEn,
              borderRadius: 18,
              imagePadding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: ColorApp.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20)),
            height: 120,
            width: 200,
          ),
          Positioned(
            left: 10,
            child: Text(
              "${itemsModel.itemsNameEn}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
