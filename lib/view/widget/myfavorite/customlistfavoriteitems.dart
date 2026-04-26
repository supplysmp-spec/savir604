import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/favorite/myfavoritecontroller.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/data/datasource/model/favoritemodel.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class CustomListFavoriteItems extends GetView<MyFavoriteController> {
  const CustomListFavoriteItems({
    super.key,
    required this.itemsModel,
  });

  final MyFavoriteModel itemsModel;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    final String title =
        translateDatabase(itemsModel.itemsNameAr, itemsModel.itemsNameEn) ?? '';
    final String description =
        translateDatabase(itemsModel.itemsDescAr, itemsModel.itemsDescEn) ?? '';

    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(28),
            ),
            child: FallbackNetworkImage(
              imageUrls: AppImageUrls.item(itemsModel.itemsImage),
              width: 118,
              height: 158,
              fit: BoxFit.cover,
              placeholder: Container(
                width: 118,
                height: 158,
                color: const Color(0xFF1C1A17),
              ),
              errorWidget: Container(
                width: 118,
                height: 158,
                color: const Color(0xFF1C1A17),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFFD6B878),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6B878).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'saved_item'.tr,
                      style: const TextStyle(
                        color: Color(0xFFD6B878),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.secondaryText,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: palette.cardAlt,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            CurrencyFormatter.egp(itemsModel.itemsPrice ?? 0),
                            style: TextStyle(
                              color: ColorApp.praimaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: itemsModel.favoriteId == null ||
                                  controller.deletingIds.contains(
                                    itemsModel.favoriteId!.toString(),
                                  )
                              ? null
                              : () {
                                  controller.deleteFromFavorite(itemsModel);
                                },
                          icon: itemsModel.favoriteId != null &&
                                  controller.deletingIds.contains(
                                    itemsModel.favoriteId!.toString(),
                                  )
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFFF26A61),
                                  ),
                                )
                              : const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFF26A61),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
