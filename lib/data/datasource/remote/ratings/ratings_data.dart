import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class RatingsData {
  final Crud crud;

  RatingsData(this.crud);

  Future<dynamic> getRatings({
    required String itemId,
    required String userId,
  }) async {
    final response = await crud.postData(
      AppLink.getRatings,
      {
        "items_id": itemId,
        "users_id": userId,
      },
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> addRating({
    required String itemId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    final response = await crud.postData(
      AppLink.addRating,
      {
        "items_id": itemId,
        "users_id": userId,
        "rating": rating.toString(),
        "comment": comment,
      },
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> updateRating({
    required String ratingId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    final response = await crud.postData(
      AppLink.updateRating,
      {
        "rating_id": ratingId,
        "users_id": userId,
        "rating": rating.toString(),
        "comment": comment,
      },
    );
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> deleteRating({
    required String itemId,
    required String userId,
  }) async {
    final response = await crud.postData(
      AppLink.deleteRating,
      {
        "items_id": itemId,
        "users_id": userId,
      },
    );
    return response.fold((l) => l, (r) => r);
  }
}
