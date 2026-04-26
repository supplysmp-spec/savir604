class OrdersArchiveModel {
  final String ordersId;
  final String ordersDatetime;
  final String ordersTotalprice;
  final String ordersStatus;
  final String itemName;
  final String itemColor;
  final String itemSize;
  final String itemPrice;
  final String itemDiscount;
  final String quantity;
  final String lineTotal;
  final String itemsImage;
  final String lensName;
  final String lensColor;
  final String lensFeatures;
  final String lensUnitPrice;
  final String lensTotalPrice;
  final String prescriptionSummary;

  OrdersArchiveModel({
    required this.ordersId,
    required this.ordersDatetime,
    required this.ordersTotalprice,
    required this.ordersStatus,
    required this.itemName,
    required this.itemColor,
    required this.itemSize,
    required this.itemPrice,
    required this.itemDiscount,
    required this.quantity,
    required this.lineTotal,
    required this.itemsImage,
    required this.lensName,
    required this.lensColor,
    required this.lensFeatures,
    required this.lensUnitPrice,
    required this.lensTotalPrice,
    required this.prescriptionSummary,
  });

  factory OrdersArchiveModel.fromJson(Map<String, dynamic> json) {
    return OrdersArchiveModel(
      ordersId: json['orders_id'].toString(),
      ordersDatetime: json['orders_datetime'],
      ordersTotalprice: json['orders_totalprice'].toString(),
      ordersStatus: json['orders_status'],
      itemName: json['item_name'] ?? '',
      itemColor: json['item_color']?.toString() ?? '',
      itemSize: json['item_size']?.toString() ?? '',
      itemPrice: json['item_price'].toString(),
      itemDiscount: json['item_discount'].toString(),
      quantity: json['quantity'].toString(),
      lineTotal: json['line_total'].toString(),
      itemsImage: json['items_image'] ?? '',
      lensName: json['lens_name']?.toString() ?? '',
      lensColor: json['lens_color']?.toString() ?? '',
      lensFeatures: json['lens_features']?.toString() ?? '',
      lensUnitPrice: json['lens_unit_price']?.toString() ?? '0',
      lensTotalPrice: json['lens_total_price']?.toString() ?? '0',
      prescriptionSummary: json['prescription_summary']?.toString() ?? '',
    );
  }
}
