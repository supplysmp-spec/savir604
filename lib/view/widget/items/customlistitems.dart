import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/favorite/favorite_controler.dart';
import 'package:tks/controler/items/items_controller.dart' show ItemsControllerImp;
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/view/widget/common/product_card_image_slider.dart';

class CustomListItems extends GetView<ItemsControllerImp> {
  const CustomListItems({super.key, required this.itemsModel});

  final ItemsModel itemsModel;

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 420;
    final int discount = int.tryParse(itemsModel.itemsDiscount ?? '0') ?? 0;
    final bool isOutOfStock = (int.tryParse(itemsModel.itemsCount ?? '0') ?? 0) <= 0;
    final String title =
        translateDatabase(itemsModel.itemsNameAr, itemsModel.itemsNameEn) ?? 'Perfume';
    final String collection = translateDatabase(
          itemsModel.categoriesNameAr,
          itemsModel.categoriesNameEn,
        ) ??
        'Precious Collection';
    final String priceText = _formattedPrice(
      itemsModel.itemsPrice,
      itemsModel.itemsDiscount,
      itemsModel.itemsDiscountPrice,
    );
    final String originalPrice = _originalPrice(itemsModel.itemsPrice);
    final String badge = (itemsModel.itemsBadge ?? '').trim();

    return InkWell(
      onTap: () => controller.goToPageProductDetails(itemsModel),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF171614),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFF34291E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: isCompact ? 12 : 13,
              child: Container(
                margin: EdgeInsets.all(isCompact ? 8 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFF121212),
                ),
                child: Hero(
                  tag: '${itemsModel.itemsId}',
                  child: ProductCardImageSlider(
                    imagePaths: itemsModel.galleryImagePaths,
                    label: title,
                    topLeft: badge.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6B878),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Color(0xFF16120D),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                    topRight: GetBuilder<FavoriteController>(
                      builder: (FavoriteController favController) => GestureDetector(
                        onTap: () async {
                          if (favController.isFavorite[itemsModel.itemsId] == '1') {
                            favController.setFavorite(itemsModel.itemsId, '0');
                            favController.removeFavorite(itemsModel.itemsId!);
                          } else {
                            favController.setFavorite(itemsModel.itemsId, '1');
                            favController.addFavorite(itemsModel.itemsId!);
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212).withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF34291E)),
                          ),
                          child: Icon(
                            favController.isFavorite[itemsModel.itemsId] == '1'
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: favController.isFavorite[itemsModel.itemsId] == '1'
                                ? const Color(0xFFD6B878)
                                : Colors.white.withValues(alpha: 0.72),
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                    bottomOverlay: isOutOfStock
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Text(
                              'Out of stock',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : discount > 0
                            ? Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB93535),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$discount% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : null,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: isCompact ? 8 : 7,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool tightHeight = constraints.maxHeight < 170;
                  final bool veryTightHeight = constraints.maxHeight < 150;
                  final double horizontalPadding = isCompact ? 12 : 14;
                  final double bottomPadding = veryTightHeight
                      ? 10
                      : isCompact
                          ? 12
                          : 14;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      4,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!veryTightHeight) ...<Widget>[
                          Text(
                            collection,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.46),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: tightHeight ? 4 : 6),
                        ],
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'myfont',
                            fontSize: veryTightHeight
                                ? 20
                                : isCompact
                                    ? 22
                                    : 24,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: tightHeight ? 6 : 8),
                        _ProductRatingLine(
                          itemsModel: itemsModel,
                          compact: tightHeight,
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                priceText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFFD6B878),
                                  fontSize: veryTightHeight
                                      ? 17
                                      : isCompact
                                          ? 18
                                          : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (discount > 0 && !veryTightHeight) ...<Widget>[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  originalPrice,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: tightHeight ? 8 : 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isOutOfStock
                                ? null
                                : () => Get.toNamed(
                                      AppRoutes.productdetails,
                                      arguments: <String, dynamic>{
                                        'itemsmodel': itemsModel,
                                      },
                                    ),
                            icon: Icon(
                              isOutOfStock
                                  ? Icons.remove_shopping_cart_outlined
                                  : Icons.shopping_bag_outlined,
                              size: veryTightHeight ? 16 : 18,
                            ),
                            label: Text(
                              isOutOfStock ? 'Out of stock' : 'View Details',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6B878),
                              foregroundColor: const Color(0xFF16120D),
                              disabledBackgroundColor: const Color(0xFF2A2926),
                              disabledForegroundColor:
                                  Colors.white.withValues(alpha: 0.42),
                              padding: EdgeInsets.symmetric(
                                vertical: veryTightHeight
                                    ? 8
                                    : isCompact
                                        ? 10
                                        : 11,
                              ),
                              textStyle: TextStyle(
                                fontSize: veryTightHeight ? 12 : 13,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedPrice(
    String? priceStr,
    String? discountStr,
    String? backendDiscountedPrice,
  ) {
    final double? backendValue = double.tryParse(backendDiscountedPrice ?? '');
    if (backendValue != null && backendValue > 0) {
      return CurrencyFormatter.egp(backendValue);
    }
    final double price = double.tryParse(priceStr ?? '0') ?? 0.0;
    final double discount = double.tryParse(discountStr ?? '0') ?? 0.0;
    final double finalPrice = price * (1 - discount / 100);
    return CurrencyFormatter.egp(finalPrice);
  }

  String _originalPrice(String? priceStr) {
    final double price = double.tryParse(priceStr ?? '0') ?? 0.0;
    return CurrencyFormatter.egp(price);
  }
}

class _ProductRatingLine extends StatelessWidget {
  const _ProductRatingLine({
    required this.itemsModel,
    this.compact = false,
  });

  final ItemsModel itemsModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final int count = itemsModel.ratingsCountValue;
    final bool hasRating = count > 0 && itemsModel.averageRatingValue > 0;

    return Row(
      children: <Widget>[
        Icon(
          Icons.star_rounded,
          size: compact ? 16 : 18,
          color: Color(0xFFF4B400),
        ),
        SizedBox(width: compact ? 3 : 4),
        Text(
          hasRating ? itemsModel.averageRatingValue.toStringAsFixed(1) : '0.0',
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: compact ? 4 : 6),
        Expanded(
          child: Text(
            hasRating ? '($count reviews)' : 'No reviews yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.44),
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
