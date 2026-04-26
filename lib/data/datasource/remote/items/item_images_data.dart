import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class ItemImagesData {
  Crud crud;
  ItemImagesData(this.crud);

  Future<dynamic> getImages(String itemId, {String? colorId}) async {
    var response = await crud.postData(
      AppLink.itemImages,
      {
        "itemid": itemId,
        if (colorId != null && colorId.isNotEmpty) "color_id": colorId,
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
