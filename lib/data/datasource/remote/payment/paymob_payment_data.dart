import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class PaymobPaymentData {
  Crud crud;
  PaymobPaymentData(this.crud);

  Future<dynamic> getIframeUrl(String userid, String amount) async {
    var response = await crud.postData(AppLink.paymobPayment, {
      "userid": userid,
      "amount": amount,
    });

    return response.fold((l) => l, (r) => r);
  }
}
