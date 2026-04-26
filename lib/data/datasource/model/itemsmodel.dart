class ItemsModel {
  String? itemsId;
  String? itemsNameEn;
  String? itemsNameAr;
  String? itemsDescEn;
  String? itemsDescAr;
  String? itemsImage;
  String? itemsCount;
  String? itemsActive;
  String? itemsPrice;
  String? itemsDiscount;
  String? itemsDiscountPrice;
  String? galleryImages;
  String? itemsDate;
  String? itemsCat;
  String? itemsColor;
  String? itemsSize;
  String? itemsPerfumeFamily;
  String? itemsConcentration;
  String? itemsGenderTarget;
  String? itemsBadge;
  String? itemsTopNotes;
  String? itemsMiddleNotes;
  String? itemsBaseNotes;
  String? itemsLongevity;
  String? itemsSillage;
  String? itemsBestFor;
  String? itemsSeasons;
  String? itemsBottleColorHex;
  String? itemsIsFeatured;
  String? itemsIsCustomizable;
  String? itemsFeaturedSort;
  String? categoriesId;
  String? categoriesNameEn;
  String? categoriesNameAr;
  String? categoriesImage;
  String? categoriesDatetime;
  String? favorite;
  String? averageRating;
  String? ratingsCount;
  String? ratingPercentage;
  String? isTopRated;

  ItemsModel({
    this.itemsId,
    this.itemsNameEn,
    this.itemsNameAr,
    this.itemsDescEn,
    this.itemsDescAr,
    this.itemsDiscountPrice,
    this.galleryImages,
    this.itemsImage,
    this.itemsCount,
    this.itemsActive,
    this.itemsPrice,
    this.itemsDiscount,
    this.itemsDate,
    this.itemsCat,
    this.itemsColor,
    this.itemsSize,
    this.itemsPerfumeFamily,
    this.itemsConcentration,
    this.itemsGenderTarget,
    this.itemsBadge,
    this.itemsTopNotes,
    this.itemsMiddleNotes,
    this.itemsBaseNotes,
    this.itemsLongevity,
    this.itemsSillage,
    this.itemsBestFor,
    this.itemsSeasons,
    this.itemsBottleColorHex,
    this.itemsIsFeatured,
    this.itemsIsCustomizable,
    this.itemsFeaturedSort,
    this.categoriesId,
    this.categoriesNameEn,
    this.categoriesNameAr,
    this.categoriesImage,
    this.categoriesDatetime,
    this.favorite,
    this.averageRating,
    this.ratingsCount,
    this.ratingPercentage,
    this.isTopRated,
  });

  ItemsModel.fromJson(Map<String, dynamic> json) {
    itemsId = json['items_id']?.toString();
    itemsNameEn = json['items_name_en']?.toString();
    itemsNameAr = json['items_name_ar']?.toString();
    itemsDescEn = json['items_desc_en']?.toString();
    itemsDescAr = json['items_desc_ar']?.toString();
    itemsImage = json['items_image']?.toString();
    itemsCount = json['items_count']?.toString();
    itemsActive = json['items_active']?.toString();
    itemsPrice = json['items_price']?.toString();
    itemsDiscount = json['items_discount']?.toString();
    itemsDiscountPrice = json['items_discount_price']?.toString() ??
        json['itemspricedisount']?.toString();
    galleryImages = json['gallery_images']?.toString();
    itemsDate = json['items_date']?.toString();
    itemsCat = json['items_cat']?.toString();
    itemsColor = json['items_color']?.toString();
    itemsSize = json['items_size']?.toString();
    itemsPerfumeFamily = json['items_perfume_family']?.toString();
    itemsConcentration = json['items_concentration']?.toString();
    itemsGenderTarget = json['items_gender_target']?.toString();
    itemsBadge = json['items_badge']?.toString();
    itemsTopNotes = json['items_top_notes']?.toString();
    itemsMiddleNotes = json['items_middle_notes']?.toString();
    itemsBaseNotes = json['items_base_notes']?.toString();
    itemsLongevity = json['items_longevity']?.toString();
    itemsSillage = json['items_sillage']?.toString();
    itemsBestFor = json['items_best_for']?.toString();
    itemsSeasons = json['items_seasons']?.toString();
    itemsBottleColorHex = json['items_bottle_color_hex']?.toString();
    itemsIsFeatured = json['items_is_featured']?.toString();
    itemsIsCustomizable = json['items_is_customizable']?.toString();
    itemsFeaturedSort = json['items_featured_sort']?.toString();
    categoriesId = json['categories_id']?.toString();
    categoriesNameEn = json['categories_name_en']?.toString();
    categoriesNameAr = json['categories_name_ar']?.toString();
    categoriesImage = json['categories_image']?.toString();
    categoriesDatetime = json['categories_datetime']?.toString();
    favorite = json['favorite']?.toString();
    averageRating = json['average_rating']?.toString();
    ratingsCount = json['ratings_count']?.toString();
    ratingPercentage = json['rating_percentage']?.toString();
    isTopRated = json['is_top_rated']?.toString();
  }

  double get itemsPriceDiscount {
    double price = double.tryParse(itemsPrice ?? '0') ?? 0;
    double discount = double.tryParse(itemsDiscount ?? '0') ?? 0;
    return price - (price * (discount / 100));
  }

  double get averageRatingValue =>
      double.tryParse(averageRating ?? '0') ?? 0.0;

  int get ratingsCountValue => int.tryParse(ratingsCount ?? '0') ?? 0;

  int get ratingPercentageValue =>
      int.tryParse(ratingPercentage ?? '0') ?? 0;

  bool get isTopRatedValue => isTopRated == '1';

  int get itemsLongevityValue => int.tryParse(itemsLongevity ?? '0') ?? 0;

  int get itemsSillageValue => int.tryParse(itemsSillage ?? '0') ?? 0;

  bool get isCustomizableValue => itemsIsCustomizable == '1';

  List<String> _csvList(String? value) {
    return (value ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<String> get topNotesList => _csvList(itemsTopNotes);

  List<String> get middleNotesList => _csvList(itemsMiddleNotes);

  List<String> get baseNotesList => _csvList(itemsBaseNotes);

  List<String> get bestForList => _csvList(itemsBestFor);

  List<String> get seasonsList => _csvList(itemsSeasons);

  List<String> get galleryImagePaths {
    final images = (galleryImages ?? '')
        .split('||')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (images.isEmpty && (itemsImage ?? '').trim().isNotEmpty) {
      images.add(itemsImage!.trim());
    }
    return images.toSet().toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items_id'] = itemsId;
    data['items_name_en'] = itemsNameEn;
    data['items_name_ar'] = itemsNameAr;
    data['items_desc_en'] = itemsDescEn;
    data['items_desc_ar'] = itemsDescAr;
    data['items_image'] = itemsImage;
    data['items_count'] = itemsCount;
    data['items_active'] = itemsActive;
    data['items_price'] = itemsPrice;
    data['items_discount'] = itemsDiscount;
    data['items_discount_price'] = itemsDiscountPrice;
    data['gallery_images'] = galleryImages;
    data['items_date'] = itemsDate;
    data['items_cat'] = itemsCat;
    data['items_color'] = itemsColor;
    data['items_size'] = itemsSize;
    data['items_perfume_family'] = itemsPerfumeFamily;
    data['items_concentration'] = itemsConcentration;
    data['items_gender_target'] = itemsGenderTarget;
    data['items_badge'] = itemsBadge;
    data['items_top_notes'] = itemsTopNotes;
    data['items_middle_notes'] = itemsMiddleNotes;
    data['items_base_notes'] = itemsBaseNotes;
    data['items_longevity'] = itemsLongevity;
    data['items_sillage'] = itemsSillage;
    data['items_best_for'] = itemsBestFor;
    data['items_seasons'] = itemsSeasons;
    data['items_bottle_color_hex'] = itemsBottleColorHex;
    data['items_is_featured'] = itemsIsFeatured;
    data['items_is_customizable'] = itemsIsCustomizable;
    data['items_featured_sort'] = itemsFeaturedSort;
    data['categories_id'] = categoriesId;
    data['categories_name_en'] = categoriesNameEn;
    data['categories_name_ar'] = categoriesNameAr;
    data['categories_image'] = categoriesImage;
    data['categories_datetime'] = categoriesDatetime;
    data['favorite'] = favorite;
    data['average_rating'] = averageRating;
    data['ratings_count'] = ratingsCount;
    data['rating_percentage'] = ratingPercentage;
    data['is_top_rated'] = isTopRated;
    return data;
  }
}
