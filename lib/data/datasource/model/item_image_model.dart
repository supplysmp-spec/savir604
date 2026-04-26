class ItemImageModel {
  final String imgPath;
  final String imgType;
  final int imgOrder;
  final String colorId;

  ItemImageModel({
    required this.imgPath,
    required this.imgType,
    required this.imgOrder,
    required this.colorId,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      imgPath: json['img_path'],
      imgType: json['img_type'],
      imgOrder: int.parse(json['img_order'].toString()),
      colorId: json['color_id']?.toString() ?? '',
    );
  }
}
