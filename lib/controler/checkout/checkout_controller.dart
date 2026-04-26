import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/cart/cart_controller.dart';
import 'package:tks/controler/delivery_controller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/addressmodel.dart';
import 'package:tks/data/datasource/model/delivery_method_model.dart';
import 'package:tks/data/datasource/remote/address/address_data.dart';
import 'package:tks/data/datasource/remote/checkout/checkout_date.dart';
import 'package:tks/data/datasource/remote/delivery_methods/delivery_methods_data.dart';
import 'package:tks/data/datasource/remote/payment/payment_data.dart';
import 'package:tks/view/screen/webview_screen.dart';

class CheckoutController extends GetxController {
  AddressData addressData = Get.put(AddressData(Get.find()));
  CheckoutData checkoutData = Get.put(CheckoutData(Get.find()));
  PaymentData paymentData = Get.put(PaymentData(Get.find()));
  DeliveryMethodsData deliveryMethodsData =
      Get.put(DeliveryMethodsData(Get.find()));
  DeliveryController deliveryController = Get.put(DeliveryController());

  MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;

  String? paymentMethod;
  String? deliveryType;
  String addressid = '0';

  late String couponid;
  late String coupondiscount;
  late String priceorders;

  List<AddressModel> dataaddress = [];
  List<DeliveryMethodModel> deliveryMethods = [];
  String? latestOrderNumber;

  String _tOrFallback(String key, String arFallback, String enFallback) {
    final translated = key.tr;
    if (translated == key) {
      return (Get.locale?.languageCode == 'ar') ? arFallback : enFallback;
    }
    return translated;
  }

  void choosePaymentMethod(String val) {
    paymentMethod = val;
    update();
  }

  void chooseDeliveryType(String val) {
    deliveryType = val;
    update();
  }

  DeliveryMethodModel? get selectedDeliveryMethod {
    if (deliveryType == null || deliveryType!.isEmpty) {
      return null;
    }
    for (final DeliveryMethodModel method in deliveryMethods) {
      if (method.id == deliveryType) {
        return method;
      }
    }
    return null;
  }

  void chooseShippingAddress(String val) {
    addressid = val;
    update();
  }

  Future<void> getShippingAddress() async {
    statusRequest = StatusRequest.loading;
    update();

    dataaddress.clear();
    addressid = '0';

    final response = await addressData.getData(
      myServices.sharedPreferences.getInt('id')!.toString(),
    );

    statusRequest = handlingData(response);

    if (StatusRequest.success == statusRequest) {
      if (response['status'] == 'success') {
        final List listdata = response['data'];
        dataaddress.addAll(listdata.map((e) => AddressModel.fromJson(e)));
        if (dataaddress.isNotEmpty) {
          addressid = dataaddress.first.addressId ?? '0';
        }
      } else {
        statusRequest = StatusRequest.success;
      }
    }
    update();
  }

  Future<void> getDeliveryMethods() async {
    deliveryMethods.clear();

    final response = await deliveryMethodsData.getMethods();
    if (response is Map && response['status'] == 'success') {
      final List listdata = response['data'] as List? ?? <dynamic>[];
      deliveryMethods.addAll(
        listdata.map((dynamic e) {
          return DeliveryMethodModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          );
        }),
      );
      if (deliveryMethods.isNotEmpty) {
        deliveryType = deliveryMethods.first.id;
      } else {
        deliveryType = null;
      }
    }
    update();
  }

  Future<void> checkout() async {
    if (paymentMethod == null) {
      Get.snackbar('Error'.tr, 'Please select a payment method'.tr);
      return;
    }
    if (deliveryType == null) {
      Get.snackbar('Error'.tr, 'Please select a order Type'.tr);
      return;
    }

    if (deliveryType == '0') {
      if (addressid == '0' || addressid.isEmpty || dataaddress.isEmpty) {
        Get.snackbar(
          _tOrFallback('134', 'تنبيه', 'Warning'),
          _tOrFallback(
            '135',
            'الرجاء إضافة عنوان للشحن قبل إتمام الطلب',
            'Please add a shipping address before checkout',
          ),
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
    }

    statusRequest = StatusRequest.loading;
    update();

    CartController cartController = Get.find<CartController>();
    priceorders = cartController.getTotalPrice().toStringAsFixed(2);
    final DeliveryMethodModel? currentMethod = selectedDeliveryMethod;
    if (currentMethod == null) {
      statusRequest = StatusRequest.none;
      update();
      Get.snackbar('Error'.tr, 'Please select a delivery option'.tr);
      return;
    }

    final String shippingFee = currentMethod.price.toStringAsFixed(2);

    final data = {
      'usersid': myServices.sharedPreferences.getInt('id')!.toString(),
      'addressid': addressid.toString(),
      'orderstype': '0',
      'delivery_method_id': currentMethod.id,
      'pricedelivery': shippingFee,
      'ordersprice': priceorders,
      'couponid': couponid,
      'coupondiscount': coupondiscount.toString(),
      'paymentmethod': paymentMethod.toString(),
    };

    if (paymentMethod == '0') {
      final response = await checkoutData.checkout(data);
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == 'success') {
          latestOrderNumber =
              'PF${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
          await myServices.sharedPreferences
              .setString('last_order_number', latestOrderNumber!);
          Get.offAllNamed(
            AppRoutes.orderSuccess,
            arguments: <String, dynamic>{'orderNumber': latestOrderNumber},
          );
        } else {
          statusRequest = StatusRequest.none;
          Get.snackbar('Error'.tr, 'Try again'.tr, colorText: Colors.white);
        }
      }
    } else if (paymentMethod == '1') {
      final response = await paymentData.initPayment({
        'user_id': myServices.sharedPreferences.getInt('id')!.toString(),
        'order_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': (
          (double.tryParse(priceorders) ?? 0) + currentMethod.price
        ).toStringAsFixed(2),
      });

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == 'success') {
          String url = response['iframe_url'];
          Get.to(() => WebViewScreen(url: url));
        } else {
          Get.snackbar('Error'.tr, 'Payment init failed'.tr);
        }
      }
    }

    update();
  }

  @override
  void onInit() {
    couponid = Get.arguments['couponid'] ?? '0';
    coupondiscount = Get.arguments['discountcoupon']?.toString() ?? '0';
    paymentMethod = '0';
    deliveryType = null;
    getShippingAddress();
    getDeliveryMethods();
    super.onInit();
  }
}
