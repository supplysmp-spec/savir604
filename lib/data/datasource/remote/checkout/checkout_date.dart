import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';
class CheckoutData {
  Crud crud;
  CheckoutData(this.crud);
  checkout(Map data) async {
    var response = await crud.postData(AppLink.checkout, data);
    return response.fold((l) => l, (r) => r);
  }
}
