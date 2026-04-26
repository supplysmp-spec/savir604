import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/items/items_controller.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/data/datasource/model/categoriesmodel.dart';

class ListCategoriesItems extends GetView<ItemsControllerImp> {
  const ListCategoriesItems({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          return Categories(
            i: index,
            categoriesModel: CategoriesModel.fromJson(controller.categories[index]),
          );
        },
      ),
    );
  }
}

class Categories extends GetView<ItemsControllerImp> {
  const Categories({
    super.key,
    required this.categoriesModel,
    required this.i,
  });

  final CategoriesModel categoriesModel;
  final int? i;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => controller.changeCat(i!, categoriesModel.categoriesId!),
      child: GetBuilder<ItemsControllerImp>(
        builder: (ItemsControllerImp controller) {
          final bool active = controller.selectedCat == i;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFD6B878) : const Color(0xFF171614),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: active ? const Color(0xFFD6B878) : const Color(0xFF34291E),
              ),
            ),
            child: Text(
              translateDatabase(
                categoriesModel.categoriesNameAr,
                categoriesModel.categoriesNameEn,
              ),
              style: TextStyle(
                fontSize: 14,
                color: active ? const Color(0xFF16120D) : Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}
