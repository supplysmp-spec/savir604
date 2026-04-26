import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/favorite/myfavoritecontroller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';
import 'package:tks/view/widget/myfavorite/customlistfavoriteitems.dart';

class MyFavorite extends StatelessWidget {
  const MyFavorite({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(MyFavoriteController());
    final palette = AppSurfacePalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.screenGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: GetBuilder<MyFavoriteController>(
            builder: (MyFavoriteController controller) {
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: AppTopBanner(
                      title: 'favorites'.tr,
                      subtitle:
                          'Keep the fragrances you want to revisit close, compare them faster, and return when you are ready.',
                      leadingIcon: Icons.arrow_back_rounded,
                      onLeadingTap: Get.back,
                      trailingIcon: Icons.favorite_rounded,
                      onTrailingTap: () {},
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: AppTopBannerMetric(
                              value: '${controller.data.length}',
                              label: 'Saved picks',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: AppTopBannerMetric(
                              value: 'Luxury',
                              label: 'Private collection',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HandlingDataView(
                        statusRequest: controller.statusRequest,
                        widget: controller.data.isEmpty
                            ? const _EmptyFavoritesState()
                            : ListView.separated(
                                itemCount: controller.data.length,
                                padding: const EdgeInsets.only(bottom: 24),
                                physics: const BouncingScrollPhysics(),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (BuildContext context, int index) {
                                  return CustomListFavoriteItems(
                                    itemsModel: controller.data[index],
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
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD6B878).withValues(alpha: 0.12),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 36,
                color: Color(0xFFD6B878),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'no_favorites_yet'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'favorites_empty_subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
