class RatingModel {
  final String ratingId;
  final String itemsId;
  final String usersId;
  final String usersName;
  final double rating;
  final String comment;
  final String createdAt;

  RatingModel({
    required this.ratingId,
    required this.itemsId,
    required this.usersId,
    required this.usersName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      ratingId: json['rating_id'].toString(),
      itemsId: json['items_id'].toString(),
      usersId: json['users_id'].toString(),
      usersName: json['users_name'] ?? "مستخدم مجهول",
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      comment: json['comment'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "rating_id": ratingId,
      "items_id": itemsId,
      "users_id": usersId,
      "users_name": usersName,
      "rating": rating.toString(),
      "comment": comment,
      "created_at": createdAt,
    };
  }
}
