import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class Testdata {
  Crud crud;
  Testdata(this.crud);
  getData(String id) async {
    var response = await crud.postData(AppLink.items, {"id": id.toString()});
    return response.fold((l) => l, (r) => r);
  }
}
