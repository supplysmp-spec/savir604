import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/home/home_controller.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/data/datasource/model/categoriesmodel.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class ListCategoriesHome extends GetView<HomeControllerImp> {
  const ListCategoriesHome({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.categories.isEmpty) {
      return const SizedBox(
        height: 126,
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return SizedBox(
      height: 116,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemCount: controller.categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Categories(
            i: index,
            categoriesModel:
                CategoriesModel.fromJson(controller.categories[index]),
          );
        },
      ),
    );
  }
}

class Categories extends GetView<HomeControllerImp> {
  final CategoriesModel categoriesModel;
  final int? i;

  const Categories({super.key, required this.categoriesModel, required this.i});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentColor((i ?? 0) % 6);
    final label = translateDatabase(
      categoriesModel.categoriesNameAr,
      categoriesModel.categoriesNameEn,
    );

    return InkWell(
      onTap: () {
        controller.goToItems(
          controller.categories,
          i!,
          categoriesModel.categoriesId!,
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.26),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcATop,
                ),
                child: FallbackNetworkImage(
                  imageUrls: AppImageUrls.category(
                    categoriesModel.categoriesImage,
                    nameEn: categoriesModel.categoriesNameEn,
                    nameAr: categoriesModel.categoriesNameAr,
                  ),
                  label: label,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(int index) {
    const palette = [
      Color(0xFF3B82F6),
      Color(0xFFA855F7),
      Color(0xFFEC4899),
      Color(0xFFF97316),
      Color(0xFF14B8A6),
      Color(0xFFEF4444),
    ];
    return palette[index % palette.length];
  }
}

