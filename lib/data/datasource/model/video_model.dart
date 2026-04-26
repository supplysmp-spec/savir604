// lib/data/models/video_model.dart
import 'package:tks/linkapi/linkapi.dart';

class VideoModel {
  final int videoId;
  final String? videoTitle;
  final String? videoDesc;
  final String videoUrl;
  final String? videoThumbnail;
  final int? videoProductId;
  int videoViews;
  int videoLikes;
  bool isLiked;
  final int? videoUserId;
  final String? videoDate;
  final String? uploaderName;
  final String? productNameAr;
  final String? productImage;

  VideoModel({
    required this.videoId,
    required this.videoUrl,
    this.videoTitle,
    this.videoDesc,
    this.videoThumbnail,
    this.videoProductId,
    required this.videoViews,
    required this.videoLikes,
    this.isLiked = false,
    this.videoUserId,
    this.videoDate,
    this.uploaderName,
    this.productNameAr,
    this.productImage,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: int.parse(json['video_id'].toString()),
      videoUrl: AppLink.normalizeUrl(json['video_url']?.toString()),
      videoTitle: json['video_title'],
      videoDesc: json['video_desc'],
      videoThumbnail: AppLink.normalizeUrl(json['video_thumbnail']?.toString()),
      videoProductId: json['video_product_id'] != null
          ? int.tryParse(json['video_product_id'].toString())
          : null,
      videoViews: int.tryParse(json['video_views'].toString()) ?? 0,
      videoLikes: int.tryParse(json['video_likes'].toString()) ?? 0,
      isLiked: json['is_liked'].toString() == '1' ||
          json['liked'].toString().toLowerCase() == 'true' ||
          json['user_liked'].toString() == '1' ||
          json['liked_by_viewer'].toString() == '1',
      videoUserId: json['video_userid'] != null
          ? int.tryParse(json['video_userid'].toString())
          : null,
      videoDate: json['video_date'],
      uploaderName: json['display_name'] ?? json['users_name'] ?? json['uploader_name'],
      productNameAr: json['product_name_ar'],
      productImage: json['product_image'],
    );
  }
}
