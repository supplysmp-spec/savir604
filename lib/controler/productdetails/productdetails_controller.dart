import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/cart/cart_controller.dart';
import 'package:tks/controler/home/home_controller.dart';
import 'package:tks/controler/items/items_controller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/item_image_model.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/data/datasource/model/product_variant_model.dart';
import 'package:tks/data/datasource/model/ratingmodel.dart';
import 'package:tks/data/datasource/remote/cart/cart_data.dart';
import 'package:tks/data/datasource/remote/items/item_images_data.dart';
import 'package:tks/data/datasource/remote/items/product_variants_data.dart';
import 'package:tks/data/datasource/remote/ratings/ratings_data.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class ProductDetailsController extends GetxController {}

class ProductDetailsControllerImp extends ProductDetailsController {
  late ItemsModel itemsModel;

  final CartData cartData = CartData(Get.find());
  final ItemImagesData imagesData = ItemImagesData(Get.find());
  final ProductVariantsData variantsData = ProductVariantsData(Get.find());
  final RatingsData ratingsData = RatingsData(Get.find());
  final MyServices myServices = Get.find();
  final PageController imagesPageController = PageController();
  final ScrollController thumbnailsScrollController = ScrollController();
  final TextEditingController ratingCommentController = TextEditingController();

  StatusRequest statusRequest = StatusRequest.loading;
  StatusRequest imagesStatus = StatusRequest.loading;
  StatusRequest variantsStatus = StatusRequest.loading;
  StatusRequest ratingsStatus = StatusRequest.loading;

  int currentImageIndex = 0;
  int countitems = 0;
  List<ItemImageModel> images = [];
  List<ProductVariantModel> variants = [];
  List<VariantColorOption> availableColors = [];
  List<VariantSizeOption> availableSizes = [];
  bool isFavorite = false;
  bool isAddingSelectedVariant = false;
  bool isSubmittingRating = false;
  double averageRating = 0;
  int ratingsCount = 0;
  int ratingPercentage = 0;
  double selectedUserRating = 0;
  String? userRatingId;
  List<RatingModel> ratings = [];

  String? selectedColorId;
  String? selectedSizeId;

  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  void onInit() async {
    itemsModel = Get.arguments['itemsmodel'];
    await getVariants();
    await getImages(colorId: selectedColorId);
    await intialData();
    await fetchRatings();
    super.onInit();
  }

  Future<void> getImages({String? colorId}) async {
    imagesStatus = StatusRequest.loading;
    final response = await imagesData.getImages(
      itemsModel.itemsId!,
      colorId: colorId,
    );
    imagesStatus = handlingData(response);

    if (imagesStatus == StatusRequest.success &&
        response['status'] == 'success') {
      images = (response['data'] as List)
          .map((e) => ItemImageModel.fromJson(e))
          .toList();
      currentImageIndex = 0;
      try {
        imagesPageController.jumpToPage(0);
      } catch (_) {}
    } else {
      images = _fallbackGalleryImages();
    }
    update();
  }

  Future<void> getVariants() async {
    variantsStatus = StatusRequest.loading;
    update();

    final response = await variantsData.getVariants(itemsModel.itemsId!);
    variantsStatus = handlingData(response);

    if (variantsStatus == StatusRequest.success &&
        response['status'] == 'success') {
      variants = (response['data'] as List)
          .map((e) => ProductVariantModel.fromJson(e))
          .toList();
      availableColors = (response['colors'] as List)
          .map((e) => VariantColorOption.fromJson(e))
          .toList();
      availableSizes = (response['sizes'] as List)
          .map((e) => VariantSizeOption.fromJson(e))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      _bootstrapSelections();
    } else {
      variants = [];
      availableColors = [];
      availableSizes = [];
    }
    update();
  }

  Future<void> intialData() async {
    statusRequest = StatusRequest.loading;
    countitems = await getCountItems(itemsModel.itemsId!);
    statusRequest = StatusRequest.success;
    averageRating = itemsModel.averageRatingValue;
    ratingsCount = itemsModel.ratingsCountValue;
    ratingPercentage = itemsModel.ratingPercentageValue;
    update();
  }

  Future<int> getCountItems(String itemsid) async {
    final response = await cartData.getCountCart(
      myServices.sharedPreferences.getInt('id')!.toString(),
      itemsid,
    );

    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest &&
        response['status'] == 'success') {
      return int.tryParse(response['data'].toString()) ?? 0;
    }
    return 0;
  }

  Future<void> selectColor(String colorId) async {
    selectedColorId = colorId;
    final sizeExists = variants.any(
      (variant) =>
          variant.colorId == selectedColorId && variant.sizeId == selectedSizeId,
    );
    if (!sizeExists) {
      selectedSizeId = variants
          .firstWhereOrNull((variant) => variant.colorId == selectedColorId)
          ?.sizeId;
    }
    await getImages(colorId: selectedColorId);
    update();
  }

  Future<void> selectSize(String sizeId) async {
    selectedSizeId = sizeId;
    final previousColorId = selectedColorId;
    final colorExists = variants.any(
      (variant) =>
          variant.colorId == selectedColorId && variant.sizeId == selectedSizeId,
    );
    if (!colorExists) {
      selectedColorId = variants
          .firstWhereOrNull((variant) => variant.sizeId == selectedSizeId)
          ?.colorId;
    }
    if (previousColorId != selectedColorId) {
      await getImages(colorId: selectedColorId);
      return;
    }
    update();
  }

  ProductVariantModel? get selectedVariant {
    if (variants.isEmpty) {
      return null;
    }
    if (selectedColorId != null && selectedSizeId != null) {
      return variants.firstWhereOrNull(
        (variant) =>
            variant.colorId == selectedColorId &&
            variant.sizeId == selectedSizeId,
      );
    }
    if (selectedColorId != null) {
      return variants.firstWhereOrNull(
        (variant) => variant.colorId == selectedColorId,
      );
    }
    if (selectedSizeId != null) {
      return variants.firstWhereOrNull(
        (variant) => variant.sizeId == selectedSizeId,
      );
    }
    if (variants.length == 1) {
      return variants.first;
    }
    return null;
  }

  List<VariantSizeOption> get selectableSizes {
    if (selectedColorId == null) return availableSizes;
    final allowed = variants
        .where((variant) => variant.colorId == selectedColorId)
        .map((variant) => variant.sizeId)
        .toSet();
    return availableSizes.where((size) => allowed.contains(size.id)).toList();
  }

  List<VariantColorOption> get selectableColors {
    if (selectedSizeId == null) return availableColors;
    final allowed = variants
        .where((variant) => variant.sizeId == selectedSizeId)
        .map((variant) => variant.colorId)
        .toSet();
    return availableColors.where((color) => allowed.contains(color.id)).toList();
  }

  bool isColorSelectable(String colorId) {
    return variants.any((variant) => variant.colorId == colorId);
  }

  bool isSizeSelectable(String sizeId) {
    return variants.any((variant) => variant.sizeId == sizeId);
  }

  double get fallbackPriceAfterDiscount {
    final discountedPrice =
        double.tryParse(itemsModel.itemsDiscountPrice ?? '') ?? 0;
    if (discountedPrice > 0) {
      return discountedPrice;
    }
    final itemPrice = double.tryParse(itemsModel.itemsPrice ?? '0') ?? 0;
    final itemDiscount = double.tryParse(itemsModel.itemsDiscount ?? '0') ?? 0;
    return itemPrice - (itemPrice * (itemDiscount / 100));
  }

  double get selectedPrice {
    return selectedVariant?.price ?? fallbackPriceAfterDiscount;
  }

  bool get hasVariants => variants.isNotEmpty;

  bool get isSelectedVariantOutOfStock =>
      selectedVariant != null && !selectedVariant!.inStock;

  String get selectedImage {
    if (images.isNotEmpty) {
      final safeIndex = currentImageIndex.clamp(0, images.length - 1);
      return images[safeIndex].imgPath;
    }
    final variantImage = selectedVariant?.imageUrl ?? '';
    if (variantImage.isNotEmpty) {
      return variantImage;
    }
    return itemsModel.itemsImage ?? '';
  }

  bool get hasMultipleImages => images.length > 1;
  bool get hasRatings => ratings.isNotEmpty;
  int get currentUserId => myServices.sharedPreferences.getInt('id') ?? 0;
  bool get hasUserRating => userRatingId != null && userRatingId!.isNotEmpty;

  Future<void> selectImageAt(
    int index, {
    bool animatePage = true,
  }) async {
    if (index < 0 || index >= images.length) {
      return;
    }
    currentImageIndex = index;
    _scrollThumbnailIntoView(index);
    if (animatePage && imagesPageController.hasClients) {
      await imagesPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
    update();
  }

  void onImagePageChanged(int index) {
    if (index < 0 || index >= images.length) {
      return;
    }
    currentImageIndex = index;
    _scrollThumbnailIntoView(index);
    update();
  }

  Future<void> addSelectedVariantToCartAndOpenCart() async {
    final bool requiresColor = availableColors.isNotEmpty;
    final bool requiresSize = availableSizes.isNotEmpty;
    final bool missingRequiredChoice =
        (requiresColor && selectedColorId == null) ||
        (requiresSize && selectedSizeId == null);

    if (hasVariants && (missingRequiredChoice || selectedVariant == null)) {
      Get.snackbar(
        isArabic ? 'اختيار غير مكتمل' : 'Incomplete selection',
        isArabic
            ? 'اختر اللون والمقاس قبل إضافة المنتج إلى السلة.'
            : 'Choose the bottle details before adding this perfume to the cart.',
      );
      return;
    }

    if (isSelectedVariantOutOfStock) {
      Get.snackbar(
        isArabic ? 'غير متاح حالياً' : 'Currently unavailable',
        isArabic
            ? 'هذا الاختيار غير متوفر حالياً. اختر لوناً أو مقاساً آخر.'
            : 'This selection is currently unavailable. Please choose another one.',
      );
      return;
    }

    final variant = selectedVariant;
    final configHash = md5
        .convert(
          utf8.encode(
            '${itemsModel.itemsId}|${variant?.variantId ?? 'default'}|${variant?.colorId ?? ''}|${variant?.sizeId ?? ''}',
          ),
        )
        .toString();

    final payload = <String, dynamic>{
      'config_hash': configHash,
      if (variant != null) 'variantid': variant.variantId,
      if (variant != null) 'item_color': variant.colorName(isArabic),
      if (variant != null) 'item_size': variant.sizeName(isArabic),
    };

    isAddingSelectedVariant = true;
    update();

    final response = await cartData.addCart(
      myServices.sharedPreferences.getInt('id')!.toString(),
      itemsModel.itemsId!,
      extraData: payload,
    );

    isAddingSelectedVariant = false;

    if (response is Map) {
      statusRequest = handlingData(response);
      if (statusRequest == StatusRequest.success &&
          response['status'] == 'success') {
        countitems++;
        update();
        final CartController cartController =
            Get.isRegistered<CartController>()
                ? Get.find<CartController>()
                : Get.put(CartController());
        await cartController.view();
        Get.toNamed(AppRoutes.cart);
        return;
      }
    }

    Get.snackbar(
      isArabic ? 'تعذر الإضافة' : 'Could not add item',
      isArabic
          ? 'حصلت مشكلة أثناء إضافة المنتج إلى السلة.'
          : 'Something went wrong while adding the product to the cart.',
    );
    update();
  }

  Future<void> fetchRatings() async {
    ratingsStatus = StatusRequest.loading;
    update();

    final response = await ratingsData.getRatings(
      itemId: itemsModel.itemsId!,
      userId: currentUserId.toString(),
    );
    ratingsStatus = handlingData(response);

    if (ratingsStatus == StatusRequest.success &&
        response['status'] == 'success') {
      averageRating =
          double.tryParse(response['average_rating'].toString()) ?? 0.0;
      ratingsCount = int.tryParse(response['total_reviews'].toString()) ?? 0;
      ratingPercentage =
          int.tryParse(response['rating_percentage'].toString()) ?? 0;
      ratings = ((response['ratings'] as List?) ?? [])
          .map((e) => RatingModel.fromJson(e))
          .toList();

      final userRating = response['user_rating'];
      if (userRating is Map) {
        userRatingId = userRating['rating_id']?.toString();
        selectedUserRating =
            double.tryParse(userRating['rating'].toString()) ?? 0.0;
        ratingCommentController.text = userRating['comment']?.toString() ?? '';
      } else {
        userRatingId = null;
        selectedUserRating = 0;
        ratingCommentController.clear();
      }

      itemsModel.averageRating = averageRating.toStringAsFixed(1);
      itemsModel.ratingsCount = ratingsCount.toString();
      itemsModel.ratingPercentage = ratingPercentage.toString();
      itemsModel.isTopRated =
          averageRating >= 4 && ratingsCount >= 3 ? '1' : '0';
      _notifyRatingConsumers();
    } else {
      ratings = [];
      averageRating = 0;
      ratingsCount = 0;
      ratingPercentage = 0;
      userRatingId = null;
      selectedUserRating = 0;
      ratingCommentController.clear();

      itemsModel.averageRating = '0.0';
      itemsModel.ratingsCount = '0';
      itemsModel.ratingPercentage = '0';
      itemsModel.isTopRated = '0';
      _notifyRatingConsumers();
    }
    update();
  }

  void setUserRating(double value) {
    selectedUserRating = value;
    update();
  }

  Future<void> submitRating() async {
    if (currentUserId <= 0) {
      Get.snackbar(
        isArabic ? 'سجل الدخول أولاً' : 'Login required',
        isArabic
            ? 'لازم تسجل دخول قبل إضافة تقييم أو تعليق.'
            : 'Please login before adding a rating or review.',
      );
      return;
    }

    if (selectedUserRating <= 0) {
      Get.snackbar(
        isArabic ? 'اختر التقييم' : 'Choose a rating',
        isArabic
            ? 'حدد عدد النجوم أولاً قبل إرسال رأيك.'
            : 'Pick your star rating before submitting your review.',
      );
      return;
    }

    isSubmittingRating = true;
    update();

    final response = hasUserRating
        ? await ratingsData.updateRating(
            ratingId: userRatingId!,
            userId: currentUserId.toString(),
            rating: selectedUserRating,
            comment: ratingCommentController.text.trim(),
          )
        : await ratingsData.addRating(
            itemId: itemsModel.itemsId!,
            userId: currentUserId.toString(),
            rating: selectedUserRating,
            comment: ratingCommentController.text.trim(),
          );

    isSubmittingRating = false;

    if (response is Map && response['status'] == 'success') {
      await fetchRatings();
      Get.snackbar(
        isArabic ? 'تم حفظ تقييمك' : 'Review saved',
        isArabic
            ? 'تم تحديث التقييم والتعليق بنجاح.'
            : 'Your rating and comment were saved successfully.',
      );
      return;
    }

    Get.snackbar(
      isArabic ? 'تعذر الحفظ' : 'Could not save review',
      isArabic
          ? 'حصلت مشكلة أثناء حفظ التقييم، حاول مرة أخرى.'
          : 'Something went wrong while saving your review.',
    );
    update();
  }

  Future<void> deleteUserRating() async {
    if (currentUserId <= 0 || !hasUserRating) {
      return;
    }

    isSubmittingRating = true;
    update();

    final response = await ratingsData.deleteRating(
      itemId: itemsModel.itemsId!,
      userId: currentUserId.toString(),
    );

    isSubmittingRating = false;

    if (response is Map && response['status'] == 'success') {
      await fetchRatings();
      Get.snackbar(
        isArabic ? 'تم حذف التقييم' : 'Review deleted',
        isArabic
            ? 'تم حذف تقييمك لهذا المنتج.'
            : 'Your review for this product was deleted.',
      );
      return;
    }

    Get.snackbar(
      isArabic ? 'تعذر الحذف' : 'Could not delete review',
      isArabic
          ? 'لم نتمكن من حذف التقييم الآن.'
          : 'We could not delete your review right now.',
    );
    update();
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    update();
  }

  Future<void> share() async {
    final websiteUri = Uri.parse('https://savir-technology.com');
    final opened = await launchUrl(
      websiteUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.snackbar(
        isArabic ? 'تعذر فتح الموقع' : 'Could not open website',
        isArabic
            ? 'حاول مرة أخرى بعد قليل.'
            : 'Please try again in a moment.',
      );
    }
  }

  @override
  void onClose() {
    imagesPageController.dispose();
    thumbnailsScrollController.dispose();
    ratingCommentController.dispose();
    super.onClose();
  }

  void _bootstrapSelections() {
    if (variants.isEmpty) return;
    selectedColorId ??= variants.first.colorId;
    selectedSizeId ??= variants
        .firstWhereOrNull((variant) => variant.colorId == selectedColorId)
        ?.sizeId;
  }

  void _scrollThumbnailIntoView(int index) {
    if (!thumbnailsScrollController.hasClients) {
      return;
    }

    const itemExtent = 86.0;
    final targetOffset = (index * itemExtent) - (itemExtent * 0.5);
    final maxOffset = thumbnailsScrollController.position.maxScrollExtent;
    final safeOffset = targetOffset.clamp(0.0, maxOffset);

    thumbnailsScrollController.animateTo(
      safeOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _notifyRatingConsumers() {
    if (Get.isRegistered<HomeControllerImp>()) {
      Get.find<HomeControllerImp>().syncProductRating(itemsModel);
    }
    if (Get.isRegistered<ItemsControllerImp>()) {
      Get.find<ItemsControllerImp>().syncProductRating(itemsModel);
    }
  }

  List<ItemImageModel> _fallbackGalleryImages() {
    return itemsModel.galleryImagePaths
        .asMap()
        .entries
        .map(
          (entry) => ItemImageModel(
            imgPath: entry.value,
            imgType: 'normal',
            imgOrder: entry.key,
            colorId: '',
          ),
        )
        .toList();
  }
}
