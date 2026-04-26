// lib/controler/video/comments_controller.dart
import 'package:get/get.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/data/datasource/model/comment_model.dart';
import 'package:tks/data/datasource/remote/video/video_remote.dart';

class CommentsController extends GetxController {
  final Crud crud;
  late final VideoRemote remote;
  final int videoId;
  final int currentUserId;

  CommentsController(
      {required this.crud,
      required this.videoId,
      required this.currentUserId}) {
    remote = VideoRemote(crud);
  }

  var comments = <CommentModel>[].obs;
  var isLoading = false.obs;
  var posting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchComments();
  }

  Future<void> fetchComments() async {
    isLoading.value = true;
    try {
      var list = await remote.getComments(videoId: videoId);
      comments.assignAll(list);
    } catch (e) {
      print("fetchComments error $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postComment(String text, {int? parentId}) async {
    if (text.trim().isEmpty) return;
    if (currentUserId == 0) {
      Get.snackbar('مطلوب تسجيل دخول', 'الرجاء تسجيل الدخول لإضافة تعليق');
      return;
    }
    posting.value = true;
    try {
      var res = await remote.addComment(
          videoId: videoId,
          userId: currentUserId,
          comment: text,
          parentId: parentId);
      if (res['status'] == 'success') {
        await fetchComments();
      } else {
        final msg = res['message'] ?? 'فشل إرسال التعليق';
        Get.snackbar('خطأ', msg);
        print("postComment failed: $res");
      }
    } catch (e) {
      print("postComment error $e");
    } finally {
      posting.value = false;
    }
  }

  Future<void> toggleLikeComment(int commentId) async {
    try {
      var res =
          await remote.likeComment(commentId: commentId, userId: currentUserId);
      if (res['status'] == 'success') {
        // refresh comment list (simple approach)
        await fetchComments();
      } else {
        final msg = res['message'] ?? 'فشل تحديث الإعجاب';
        Get.snackbar('خطأ', msg);
      }
    } catch (e) {
      print("toggleLikeComment $e");
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      var res = await remote.deleteComment(
        commentId: commentId,
        userId: currentUserId,
      );
      if (res['status'] == 'success') {
        await fetchComments();
      } else {
        final msg = res['message'] ?? 'تعذر حذف التعليق';
        Get.snackbar('خطأ', msg);
      }
    } catch (e) {
      print("deleteComment $e");
    }
  }
}
