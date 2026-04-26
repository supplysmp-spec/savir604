import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';
class CartData {
  Crud crud;
  CartData(this.crud);
  addCart(
    String usersid,
    String? itemsid, {
    String? customPerfumeId,
    String? cartItemType,
    String? size,
    String? color,
    Map<String, dynamic>? extraData,
  }) async {
    final payload = {
      "usersid": usersid,
      if (itemsid != null && itemsid.isNotEmpty) "itemsid": itemsid,
      if (customPerfumeId != null && customPerfumeId.isNotEmpty)
        "custom_perfume_id": customPerfumeId,
      if (cartItemType != null && cartItemType.isNotEmpty)
        "cart_item_type": cartItemType,
      ...?extraData,
    };
    var response = await crud.postData(AppLink.cartadd, payload);
    return response.fold((l) => l, (r) => r);
  }

  deleteCart(String usersid, {String? itemsid, String? cartid}) async {
    final payload = {
      "usersid": usersid,
      if (itemsid != null) "itemsid": itemsid,
      if (cartid != null) "cartid": cartid,
    };
    var response = await crud.postData(AppLink.cartdelete, payload);
    return response.fold((l) => l, (r) => r);
  }

  getCountCart(String usersid, String itemsid) async {
    var response = await crud.postData(
        AppLink.cartgetcountitems, {"usersid": usersid, "itemsid": itemsid});
    return response.fold((l) => l, (r) => r);
  }

  viewCart(String usersid) async {
    var response = await crud.postData(AppLink.cartview, {
      "usersid": usersid,
    });
    return response.fold((l) => l, (r) => r);
  }

  checkCoupon(String couponname) async {
    var response =
        await crud.postData(AppLink.checkcoupon, {"couponname": couponname});
    return response.fold((l) => l, (r) => r);
  }
}
