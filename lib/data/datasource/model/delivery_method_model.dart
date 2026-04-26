class DeliveryMethodModel {
  DeliveryMethodModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    required this.etaAr,
    required this.etaEn,
    required this.sort,
    required this.active,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final String etaAr;
  final String etaEn;
  final int sort;
  final bool active;

  factory DeliveryMethodModel.fromJson(Map<String, dynamic> json) {
    return DeliveryMethodModel(
      id: (json['delivery_method_id'] ?? '').toString(),
      nameAr: (json['delivery_method_name_ar'] ?? '').toString(),
      nameEn: (json['delivery_method_name_en'] ?? '').toString(),
      descriptionAr:
          (json['delivery_method_description_ar'] ?? '').toString(),
      descriptionEn:
          (json['delivery_method_description_en'] ?? '').toString(),
      price: double.tryParse(
            (json['delivery_method_price'] ?? '0').toString(),
          ) ??
          0,
      etaAr: (json['delivery_method_eta_ar'] ?? '').toString(),
      etaEn: (json['delivery_method_eta_en'] ?? '').toString(),
      sort: int.tryParse((json['delivery_method_sort'] ?? '0').toString()) ?? 0,
      active: (json['delivery_method_active'] ?? '0').toString() == '1',
    );
  }

  String displayName(bool isArabic) =>
      isArabic ? (nameAr.isNotEmpty ? nameAr : nameEn) : (nameEn.isNotEmpty ? nameEn : nameAr);

  String displayDescription(bool isArabic) => isArabic
      ? (descriptionAr.isNotEmpty ? descriptionAr : descriptionEn)
      : (descriptionEn.isNotEmpty ? descriptionEn : descriptionAr);

  String displayEta(bool isArabic) =>
      isArabic ? (etaAr.isNotEmpty ? etaAr : etaEn) : (etaEn.isNotEmpty ? etaEn : etaAr);
}
