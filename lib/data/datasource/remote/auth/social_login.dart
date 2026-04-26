import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class SocialLoginData {
  SocialLoginData(this.crud);

  final Crud crud;

  Future<dynamic> postData({
    required String provider,
    required String socialId,
    required String email,
    required String name,
    String? photoUrl,
  }) async {
    final response = await crud.postData(
      AppLink.socialLogin,
      {
        "provider": provider,
        "social_id": socialId,
        "email": email,
        "username": name,
        "photo": photoUrl ?? "",
      },
    );

    return response.fold((l) => l, (r) => r);
  }
}
