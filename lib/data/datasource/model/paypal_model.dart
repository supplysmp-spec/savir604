class PayPalModel {
  String paymentStatus;
  String paymentAmount;
  String userId;
  String orderId;

  PayPalModel({
    required this.paymentStatus,
    required this.paymentAmount,
    required this.userId,
    required this.orderId,
  });

  // تحويل البيانات إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'payment_status': paymentStatus,
      'payment_amount': paymentAmount,
      'user_id': userId,
      'order_id': orderId,
    };
  }

  // تحويل JSON إلى كائن
  factory PayPalModel.fromJson(Map<String, dynamic> json) {
    return PayPalModel(
      paymentStatus: json['payment_status'],
      paymentAmount: json['payment_amount'],
      userId: json['user_id'],
      orderId: json['order_id'],
    );
  }
}
