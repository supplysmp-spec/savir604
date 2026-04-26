import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class FragrancePricingData {
  FragrancePricingData(this.crud);

  final Crud crud;

  Future<dynamic> getConfig() async {
    final response = await crud.postData(
      AppLink.fragrancePricingConfig,
      <String, dynamic>{},
    );
    return response.fold((l) => l, (r) => r);
  }
}
