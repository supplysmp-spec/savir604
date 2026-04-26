class CouponModel {
  String? couponId;
  String? couponName;
  String? couponCount;
  String? couponDiscount;
  String? couponExpiredate;

  CouponModel(
      {this.couponId,
      this.couponName,
      this.couponCount,
      this.couponDiscount,
      this.couponExpiredate});

  CouponModel.fromJson(Map<String, dynamic> json) {
    // Some backends return numeric values (int) for these fields.
    // Convert safely to String to avoid type errors when assigning to String? fields.
    couponId = json['coupon_id']?.toString();
    couponName = json['coupon_name']?.toString();
    couponCount = json['coupon_count']?.toString();
    couponDiscount = json['coupon_discount']?.toString();
    couponExpiredate = json['coupon_expiredate']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['coupon_id'] = couponId;
    data['coupon_name'] = couponName;
    data['coupon_count'] = couponCount;
    data['coupon_discount'] = couponDiscount;
    data['coupon_expiredate'] = couponExpiredate;
    return data;
  }
}
