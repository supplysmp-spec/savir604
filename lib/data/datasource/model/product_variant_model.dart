class VariantColorOption {
  final String id;
  final String nameAr;
  final String nameEn;
  final String hex;

  const VariantColorOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.hex,
  });

  factory VariantColorOption.fromJson(Map<String, dynamic> json) {
    final fallbackName = json['color_name']?.toString() ?? '';
    return VariantColorOption(
      id: json['color_id']?.toString() ?? '',
      nameAr: json['color_name_ar']?.toString() ?? fallbackName,
      nameEn: json['color_name_en']?.toString() ?? fallbackName,
      hex: json['color_hex']?.toString() ?? json['hex']?.toString() ?? '#D1D5DB',
    );
  }

  String displayName(bool isArabic) => isArabic ? nameAr : nameEn;
}

class VariantSizeOption {
  final String id;
  final String nameAr;
  final String nameEn;
  final int order;

  const VariantSizeOption({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.order,
  });

  factory VariantSizeOption.fromJson(Map<String, dynamic> json) {
    final fallbackName = json['size_name']?.toString() ?? '';
    return VariantSizeOption(
      id: json['size_id']?.toString() ?? '',
      nameAr: json['size_name_ar']?.toString() ?? fallbackName,
      nameEn: json['size_name_en']?.toString() ?? fallbackName,
      order: int.tryParse(
            json['size_order']?.toString() ?? json['order']?.toString() ?? '0',
          ) ??
          0,
    );
  }

  String displayName(bool isArabic) => isArabic ? nameAr : nameEn;
}

class ProductVariantModel {
  final String variantId;
  final String itemId;
  final String colorId;
  final String sizeId;
  final String variantLabel;
  final int volumeMl;
  final int stock;
  final double price;
  final String imageUrl;
  final String colorNameAr;
  final String colorNameEn;
  final String colorHex;
  final String sizeNameAr;
  final String sizeNameEn;
  final int sizeOrder;

  const ProductVariantModel({
    required this.variantId,
    required this.itemId,
    required this.colorId,
    required this.sizeId,
    required this.variantLabel,
    required this.volumeMl,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.colorNameAr,
    required this.colorNameEn,
    required this.colorHex,
    required this.sizeNameAr,
    required this.sizeNameEn,
    required this.sizeOrder,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final fallbackColor = json['color_name']?.toString() ?? '';
    final fallbackSize = json['size_name']?.toString() ?? '';
    return ProductVariantModel(
      variantId: json['variant_id']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      colorId: json['color_id']?.toString() ?? '',
      sizeId: json['size_id']?.toString() ?? '',
      variantLabel: json['variant_label']?.toString() ?? '',
      volumeMl: int.tryParse(json['variant_volume_ml']?.toString() ?? '0') ?? 0,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      colorNameAr: json['color_name_ar']?.toString() ?? fallbackColor,
      colorNameEn: json['color_name_en']?.toString() ?? fallbackColor,
      colorHex: json['color_hex']?.toString() ?? '#D1D5DB',
      sizeNameAr: json['size_name_ar']?.toString() ?? fallbackSize,
      sizeNameEn: json['size_name_en']?.toString() ?? fallbackSize,
      sizeOrder: int.tryParse(json['size_order']?.toString() ?? '0') ?? 0,
    );
  }

  bool get inStock => stock > 0;

  String colorName(bool isArabic) => isArabic ? colorNameAr : colorNameEn;

  String sizeName(bool isArabic) {
    if (volumeMl > 0) {
      return '$volumeMl ml';
    }
    final String preferred = isArabic ? sizeNameAr : sizeNameEn;
    if (preferred.isNotEmpty) {
      return preferred;
    }
    if (variantLabel.isNotEmpty) {
      return variantLabel;
    }
    return '';
  }
}
