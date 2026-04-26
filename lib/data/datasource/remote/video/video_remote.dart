// lib/data/data_sources/video_remote.dart

import 'package:tks/core/class/crud.dart';
import 'package:tks/data/datasource/model/comment_model.dart';
import 'package:tks/data/datasource/model/video_model.dart';
import 'package:tks/linkapi/linkapi.dart';

class VideoRemote {
  final Crud crud;
  VideoRemote(this.crud);

  // ===================== GET VIDEOS =====================
  Future<List<VideoModel>> fetchVideos({int? viewerId}) async {
    var res = await crud.postData(AppLink.reelsFeed, {
      "viewer_id": "${viewerId ?? 0}",
      "mode": "public",
    });

    return res.fold(
      (l) => <VideoModel>[],
      (r) {
        if (r is Map && r.containsKey('data') && r['data'] is List) {
          return (r['data'] as List)
              .map((e) => VideoModel.fromJson(e))
              .toList();
        }

        print("⚠️ Unexpected videos response: $r");
        return <VideoModel>[];
      },
    );
  }

  // ===================== LIKE VIDEO =====================
  Future<Map<String, dynamic>> addLike({
    required int videoId,
    required int userId,
  }) async {
    var res = await crud.postData(AppLink.addLike, {
      "videoid": videoId.toString(),
      "userid": userId.toString(),
    });

    return res.fold(
        (l) => {"status": "error"},
        (r) => r is Map
            ? Map<String, dynamic>.from(r)
            : {"status": "error", "raw": r});
  }

  // ===================== VIEW COUNTER =====================
  Future<void> increaseView({required int videoId, int? userId}) async {
    await crud.postData(AppLink.increaseView, {
      "videoid": videoId.toString(),
      "userid": userId?.toString() ?? "",
    });
  }

  // ===================== GET COMMENTS =====================
  Future<List<CommentModel>> getComments({required int videoId}) async {
    var res = await crud.postData(AppLink.getComments, {
      "videoid": videoId.toString(),
    });

    return res.fold(
      (l) => <CommentModel>[],
      (r) {
        if (r is Map &&
            r.containsKey('status') &&
            r['status'] == 'success' &&
            r.containsKey('data') &&
            r['data'] is List) {
          return (r['data'] as List)
              .map((e) => CommentModel.fromJson(e))
              .toList();
        }

        print("⚠️ Unexpected comments response: $r");
        return <CommentModel>[];
      },
    );
  }

  // ===================== ADD COMMENT =====================
  Future<Map<String, dynamic>> addComment({
    required int videoId,
    required int userId,
    required String comment,
    int? parentId,
  }) async {
    final Map<String, String> data = {
      "videoid": videoId.toString(),
      "userid": userId.toString(),
      "comment": comment,
    };

    // Only include parentid when replying to a comment
    if (parentId != null) {
      data['parentid'] = parentId.toString();
    }

    print("addComment sending data: $data");
    var res = await crud.postData(AppLink.addComment, data);

    return res.fold(
        (l) => {"status": "error"},
        (r) => r is Map
            ? Map<String, dynamic>.from(r)
            : {"status": "error", "raw": r});
  }

  // ===================== LIKE COMMENT =====================
  Future<Map<String, dynamic>> likeComment({
    required int commentId,
    required int userId,
  }) async {
    var res = await crud.postData(AppLink.likeComment, {
      "commentid": commentId.toString(),
      "userid": userId.toString(),
    });

    return res.fold(
        (l) => {"status": "error"},
        (r) => r is Map
            ? Map<String, dynamic>.from(r)
            : {"status": "error", "raw": r});
  }

  Future<Map<String, dynamic>> deleteComment({
    required int commentId,
    required int userId,
  }) async {
    var res = await crud.postData(AppLink.deleteVideoComment, {
      "commentid": commentId.toString(),
      "userid": userId.toString(),
    });

    return res.fold(
      (l) => {"status": "error"},
      (r) => r is Map
          ? Map<String, dynamic>.from(r)
          : {"status": "error", "raw": r},
    );
  }
}
