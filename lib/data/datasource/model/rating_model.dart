// ignore_for_file: camel_case_types, unnecessary_new, prefer_collection_literals, unnecessary_this

class model_rating {
  String? status;
  double? averageRating;
  int? totalReviews;
  List<Ratings>? ratings;

  model_rating(
      {this.status, this.averageRating, this.totalReviews, this.ratings});

  model_rating.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    averageRating = json['average_rating'];
    totalReviews = json['total_reviews'];
    if (json['ratings'] != null) {
      ratings = <Ratings>[];
      json['ratings'].forEach((v) {
        ratings!.add(new Ratings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['average_rating'] = this.averageRating;
    data['total_reviews'] = this.totalReviews;
    if (this.ratings != null) {
      data['ratings'] = this.ratings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Ratings {
  int? ratingId;
  int? itemsId;
  int? usersId;
  int? rating;
  String? comment;
  String? createdAt;
  String? usersName;

  Ratings(
      {this.ratingId,
      this.itemsId,
      this.usersId,
      this.rating,
      this.comment,
      this.createdAt,
      this.usersName});

  Ratings.fromJson(Map<String, dynamic> json) {
    ratingId = json['rating_id'];
    itemsId = json['items_id'];
    usersId = json['users_id'];
    rating = json['rating'];
    comment = json['comment'];
    createdAt = json['created_at'];
    usersName = json['users_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rating_id'] = this.ratingId;
    data['items_id'] = this.itemsId;
    data['users_id'] = this.usersId;
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['created_at'] = this.createdAt;
    data['users_name'] = this.usersName;
    return data;
  }
}
