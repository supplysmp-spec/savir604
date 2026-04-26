import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';
class ItemsData {
  Crud crud;
  ItemsData(this.crud);

  Future<dynamic> getData(String id, String userid) async {
    var response = await crud
        .postData(AppLink.items, {"id": id.toString(), "usersid": userid});
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> searchData(String searchQuery) async {
    var response =
        await crud.postData(AppLink.searchitems, {"search": searchQuery});
    return response.fold((l) => l, (r) => r);
  }
}
