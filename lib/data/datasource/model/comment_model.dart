import 'dart:convert';

class CommentModel {
  final int commentId;
  final int videoId;
  final int userId;
  final String commentText;
  int commentLikes;
  final String commentDate;
  final String usersName;
  final String userRole;
  List<CommentModel> replies;

  CommentModel({
    required this.commentId,
    required this.videoId,
    required this.userId,
    required this.commentText,
    required this.commentLikes,
    required this.commentDate,
    required this.usersName,
    required this.userRole,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    int safeParseId(Object? value) =>
        int.tryParse(value?.toString() ?? '') ?? 0;

    return CommentModel(
      commentId: safeParseId(json['comment_id']),
      videoId: safeParseId(json['video_id']),
      userId: safeParseId(json['user_id']),
      commentText: _normalizeText(json['comment_text']),
      commentLikes: int.tryParse(json['comment_likes']?.toString() ?? '') ?? 0,
      commentDate: _normalizeText(json['comment_date']),
      usersName: _normalizeText(json['users_name']),
      userRole: _normalizeText(json['user_role'], fallback: 'user'),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) return CommentModel.fromJson(e);
                return null;
              })
              .whereType<CommentModel>()
              .toList() ??
          [],
    );
  }

  static String _normalizeText(Object? value, {String fallback = ''}) {
    final String text = value?.toString() ?? fallback;
    if (text.isEmpty) return fallback;
    if (!_looksMisencoded(text)) return text;

    try {
      return utf8.decode(latin1.encode(text));
    } catch (_) {
      return text;
    }
  }

  static bool _looksMisencoded(String text) {
    return text.contains('\u00D8') ||
        text.contains('\u00D9') ||
        text.contains('\u00C3') ||
        text.contains('\u00C2');
  }
}
