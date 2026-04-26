import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/favorite/favorite_controler.dart';
import 'package:tks/controler/items/items_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/view/widget/items/customlistitems.dart';
import 'package:tks/view/widget/items/listcategoirseitems.dart';

class Items extends StatelessWidget {
  const Items({super.key});

  @override
  Widget build(BuildContext context) {
    final ItemsControllerImp itemsController = Get.put(ItemsControllerImp());
    final FavoriteController favoriteController = Get.put(FavoriteController());

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<ItemsControllerImp>(
          builder: (ItemsControllerImp controller) {
            final int itemCount = controller.data.length;

            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            _CircleButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: Get.back,
                            ),
                            const Spacer(),
                            _CircleButton(
                              icon: Icons.favorite_border_rounded,
                              onTap: () => Get.toNamed(AppRoutes.myfavroite),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Precious Collection'.tr,
                          style: TextStyle(
                            color:
                                const Color(0xFFD6B878).withValues(alpha: 0.92),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover Your Signature Scent'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'myfont',
                            fontSize: 31,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$itemCount ${'luxury fragrances curated for a premium experience.'.tr}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _LuxurySearchBar(controller: itemsController),
                        const SizedBox(height: 18),
                        const ListCategoriesItems(),
                        const SizedBox(height: 16),
                        _CollectionSummary(itemCount: itemCount),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                  sliver: SliverToBoxAdapter(
                    child: HandlingDataView(
                      statusRequest: controller.statusRequest,
                      widget: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final double width = constraints.maxWidth;
                          int crossAxisCount = 2;
                          double childAspectRatio = 0.49;

                          if (width >= 1180) {
                            crossAxisCount = 5;
                            childAspectRatio = 0.62;
                          } else if (width >= 900) {
                            crossAxisCount = 4;
                            childAspectRatio = 0.59;
                          } else if (width >= 640) {
                            crossAxisCount = 3;
                            childAspectRatio = 0.56;
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.data.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final itemId = controller.data[index]['items_id'];
                              final isFavorite =
                                  controller.data[index]['favorite'];
                              favoriteController.isFavorite[itemId] =
                                  isFavorite;

                              return CustomListItems(
                                itemsModel:
                                    ItemsModel.fromJson(controller.data[index]),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF151515),
          border: Border.all(color: const Color(0xFF2E261B)),
        ),
        child: Icon(icon, color: const Color(0xFFD6B878), size: 18),
      ),
    );
  }
}

class _LuxurySearchBar extends StatelessWidget {
  const _LuxurySearchBar({required this.controller});

  final ItemsControllerImp controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171614),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF34291E)),
            ),
            child: TextField(
              controller: controller.search,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => controller.onSearchItems(),
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFD6B878),
                ),
                hintText: 'Find your fragrance'.tr,
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFD6B878),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: controller.onSearchItems,
            icon: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF16120D),
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionSummary extends StatelessWidget {
  const _CollectionSummary({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171614),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF34291E)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFD6B878).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFD6B878),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$itemCount ${'Fragrances Available'.tr}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse refined scents, compare bottles, and discover your next signature perfume.'
                      .tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
