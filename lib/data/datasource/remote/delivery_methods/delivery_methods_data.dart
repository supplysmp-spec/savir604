import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class DeliveryMethodsData {
  DeliveryMethodsData(this.crud);

  final Crud crud;

  Future<dynamic> getMethods() async {
    final response = await crud.postData(AppLink.deliveryMethods, {});
    return response.fold((l) => l, (r) => r);
  }
}
