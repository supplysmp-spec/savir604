import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class ProductVariantsData {
  final Crud crud;

  ProductVariantsData(this.crud);

  Future<dynamic> getVariants(String itemId) async {
    final response = await crud.postData(
      AppLink.getProductVariants,
      {"itemid": itemId},
    );
    return response.fold((l) => l, (r) => r);
  }
}
