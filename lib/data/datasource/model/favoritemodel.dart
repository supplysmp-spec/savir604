class MyFavoriteModel {
  int? favoriteId;
  int? favoriteUsersid;
  int? favoriteItemsid;
  int? itemsId;
  String? itemsNameEn;
  String? itemsNameAr;
  String? itemsDescEn;
  String? itemsDescAr;
  String? itemsImage;
  int? itemsCount;
  int? itemsActive;
  double? itemsPrice;   // خليته double عشان السعر ممكن يبقى 860.00
  int? itemsDiscount;
  String? itemsDate;
  int? itemsCat;
  int? usersId;

  MyFavoriteModel({
    this.favoriteId,
    this.favoriteUsersid,
    this.favoriteItemsid,
    this.itemsId,
    this.itemsNameEn,
    this.itemsNameAr,
    this.itemsDescEn,
    this.itemsDescAr,
    this.itemsImage,
    this.itemsCount,
    this.itemsActive,
    this.itemsPrice,
    this.itemsDiscount,
    this.itemsDate,
    this.itemsCat,
    this.usersId,
  });

  MyFavoriteModel.fromJson(Map<String, dynamic> json) {
    favoriteId = int.tryParse(json['favorite_id'].toString());
    favoriteUsersid = int.tryParse(json['favorite_usersid'].toString());
    favoriteItemsid = int.tryParse(json['favorite_itemsid'].toString());
    itemsId = int.tryParse(json['items_id'].toString());
    itemsNameEn = json['items_name_en']?.toString();
    itemsNameAr = json['items_name_ar']?.toString();
    itemsDescEn = json['items_desc_en']?.toString();
    itemsDescAr = json['items_desc_ar']?.toString();
    itemsImage = json['items_image']?.toString();
    itemsCount = int.tryParse(json['items_count'].toString());
    itemsActive = int.tryParse(json['items_active'].toString());
    itemsPrice = double.tryParse(json['items_price'].toString());
    itemsDiscount = int.tryParse(json['items_discount'].toString());
    itemsDate = json['items_date']?.toString();
    itemsCat = int.tryParse(json['items_cat'].toString());
    usersId = int.tryParse(json['users_id'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['favorite_id'] = favoriteId;
    data['favorite_usersid'] = favoriteUsersid;
    data['favorite_itemsid'] = favoriteItemsid;
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
    data['items_date'] = itemsDate;
    data['items_cat'] = itemsCat;
    data['users_id'] = usersId;
    return data;
  }
}
