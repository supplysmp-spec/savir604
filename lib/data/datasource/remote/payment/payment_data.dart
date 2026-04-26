import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';
class PaymentData {
  Crud crud;
  PaymentData(this.crud);

  initPayment(Map<String, dynamic> data) async {
    var response = await crud.postData(AppLink.initPayment, data);
    return response.fold((l) => l, (r) => r);
  }
}
