// ignore_for_file: avoid_print

import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/cartmodel.dart';
import 'package:tks/data/datasource/model/couponmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/data/datasource/remote/cart/cart_data.dart';

class CartController extends GetxController {
  TextEditingController? controllercoupon;
  CartData cartData = CartData(Get.find());
  // Use double for discount to safely support fractional discounts like 10.5
  double discountcoupon = 0.0;
  String? couponname;
  String? couponid;
  late StatusRequest statusRequest;
  CouponModel? couponModel;
  bool isCheckingCoupon = false;
  MyServices myServices = Get.find();
  List<CartModel> data = [];
  double priceorders = 0.0;
  int totalcountitems = 0;

  // إضافة منتج للسلة وتحديث الـ UI مباشرة
  add(String? itemsid, {String? cartid, String? customPerfumeId}) async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await cartData.addCart(
      myServices.sharedPreferences.getInt("id")!.toString(),
      itemsid,
      customPerfumeId: customPerfumeId,
      cartItemType:
          customPerfumeId != null && customPerfumeId.isNotEmpty ? 'custom_perfume' : null,
      extraData: cartid == null ? null : {'cartid': cartid},
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.rawSnackbar(
            title: "اشعار",
            messageText: const Text("تم اضافة المنتج الى السلة "));

        // ✅ تحديث السلة فورًا بعد الإضافة
        await view();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  Future<bool> addCustomPerfume(String customPerfumeId) async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await cartData.addCart(
      myServices.sharedPreferences.getInt("id")!.toString(),
      null,
      customPerfumeId: customPerfumeId,
      cartItemType: 'custom_perfume',
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest && response['status'] == "success") {
      await view();
      update();
      return true;
    }

    update();
    return false;
  }

  goToPageCheckout() {
    if (data.isEmpty) {
      return Get.snackbar("تنبيه", "السلة فارغة");
    }
    Get.toNamed(AppRoutes.checkout, arguments: {
      "couponid": couponid ?? "0",
      "priceorder": priceorders.toString(),
      "discountcoupon": discountcoupon.toString(),
    })!
        .then((_) {
      clearCart(); // امسح السلة بعد تأكيد الطلب
    });
  }

  clearCart() {
    data.clear();
    totalcountitems = 0;
    priceorders = 0.0;
    update();
    Get.snackbar("تنبيه", "تم إزالة جميع المنتجات من السلة");
  }

  double getTotalPrice() {
    return getFinalTotal();
  }

  double getSubtotal() {
    double subtotal = 0.0;
    for (var item in data) {
      double lineSubtotal = double.tryParse(item.lineSubtotal ?? '0.0') ?? 0.0;
      subtotal += lineSubtotal;
    }
    return subtotal;
  }

  double getTotalAfterItemDiscounts() {
    double total = 0.0;
    for (var item in data) {
      double lineTotal = double.tryParse(item.lineTotal ?? '0.0') ?? 0.0;
      total += lineTotal;
    }
    return total;
  }

  double getTotalItemsDiscountAmount() {
    double discount = 0.0;
    for (var item in data) {
      discount += double.tryParse(item.lineDiscount ?? '0.0') ?? 0.0;
    }
    return discount;
  }

  double getCouponDiscountAmount() {
    final afterItems = getTotalAfterItemDiscounts();
    if (discountcoupon > 0) {
      return afterItems * (discountcoupon / 100);
    }
    return 0.0;
  }

  double getFinalTotal() {
    final afterItems = getTotalAfterItemDiscounts();
    final couponAmt = getCouponDiscountAmount();
    return afterItems - couponAmt;
  }

  delete({String? itemsid, String? cartid}) async {
    statusRequest = StatusRequest.loading;
    update();

    var response = await cartData.deleteCart(
      myServices.sharedPreferences.getInt("id")!.toString(),
      itemsid: itemsid,
      cartid: cartid,
    );
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.rawSnackbar(
            title: "اشعار",
            messageText: const Text("تم ازالة المنتج من السلة "));
        await view(); // تحديث السلة فورًا بعد الحذف
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  // التحقق من الكوبون وتحديث الخصم فورًا
  checkcoupon() async {
    if (controllercoupon?.text.trim().isEmpty ?? true) return;
    isCheckingCoupon = true;
    update();

    var response = await cartData.checkCoupon(controllercoupon!.text.trim());
    // Log the raw response to make debugging easier (server may return ints or unexpected shapes)
    print('checkcoupon response status: ${response.runtimeType}');
    print('checkcoupon response body: $response');
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        final datacoupon = response['data'];
        if (datacoupon == null) {
          // unexpected null data
          Get.snackbar('Warning', 'Coupon response has empty data');
        } else if (datacoupon is Map<String, dynamic>) {
          couponModel = CouponModel.fromJson(datacoupon);
        } else {
          // Sometimes response['data'] could be non-map (e.g., list or scalar) — coerce to Map if possible
          try {
            final coerced = Map<String, dynamic>.from(datacoupon);
            couponModel = CouponModel.fromJson(coerced);
          } catch (e) {
            Get.snackbar('Warning', 'Unexpected coupon data format');
          }
        }
        // sanitize & parse discount safely as double (API may return "10", "10%", "10.5" or with spaces)
        final rawDiscount = couponModel!.couponDiscount ?? '0';
        final sanitized = rawDiscount.replaceAll(RegExp(r'[^0-9\.]'), '');
        final parsed = double.tryParse(sanitized);
        discountcoupon = parsed ?? 0.0;
        // Guard: if couponModel parsing failed then parsed may be null
        if (couponModel == null) {
          Get.snackbar('Warning', 'Coupon parsing failed');
        }
        couponname = couponModel!.couponName;
        couponid = couponModel!.couponId;
        Get.snackbar('Coupon applied', '${couponname} - ${discountcoupon}%');

        update(); // تحديث الـ UI فورًا بعد تطبيق الكوبون
      } else {
        discountcoupon = 0.0;
        couponname = null;
        couponid = null;
        Get.snackbar("Warning", "Coupon Not Valid");
        update();
      }
    }

    isCheckingCoupon = false;
    update();
  }

  void removeCoupon() {
    couponModel = null;
    discountcoupon = 0.0;
    couponname = null;
    couponid = null;
    controllercoupon?.clear();
    Get.snackbar('Coupon removed', 'Coupon has been cleared');
    update();
  }

  resetVarCart() {
    totalcountitems = 0;
    priceorders = 0.0;
    data.clear();
  }

  refreshPage() {
    resetVarCart();
    view();
  }

  // جلب بيانات السلة من السيرفر وتحديث القائمة فورًا
  view() async {
    statusRequest = StatusRequest.loading;
    update();
    var response = await cartData
        .viewCart(myServices.sharedPreferences.getInt("id")!.toString());
    print("=============================== Controller $response ");
    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        List dataresponse = response['datacart'];
        Map dataresponsecountprice = response['countprice'];

        data.clear();
        data.addAll(dataresponse.map((e) => CartModel.fromJson(e)));
        totalcountitems =
            int.parse(dataresponsecountprice['totalcount'].toString());
        priceorders =
            double.parse(dataresponsecountprice['totalprice'].toString());
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    controllercoupon = TextEditingController();
    view();
    super.onInit();
  }
}
