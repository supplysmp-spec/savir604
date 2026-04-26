import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/linkapi/linkapi.dart';

class FragranceSocialData {
  FragranceSocialData(this.crud);

  final Crud crud;

  Future<Map<String, dynamic>> getProfile({
    required int userId,
    int? viewerId,
  }) async {
    final response = await crud.postData(
      AppLink.userProfileGet,
      <String, dynamic>{
        'user_id': '$userId',
        'viewer_id': '${viewerId ?? userId}',
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> discoverProfiles({
    required int viewerId,
    int limit = 100,
  }) async {
    final response = await crud.postData(
      AppLink.userProfileDiscover,
      <String, dynamic>{
        'viewer_id': '$viewerId',
        'limit': '$limit',
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? displayName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? gender,
    String? favoriteFamily,
    String profileVisibility = 'public',
    bool isCreator = false,
  }) async {
    final response = await crud.postData(
      AppLink.userProfileUpdate,
      <String, dynamic>{
        'user_id': '$userId',
        'display_name': displayName ?? '',
        'username': username ?? '',
        'bio': bio ?? '',
        'avatar_url': AppLink.normalizeUrl(avatarUrl),
        'cover_url': AppLink.normalizeUrl(coverUrl),
        'gender': gender ?? '',
        'favorite_family': favoriteFamily ?? '',
        'profile_visibility': profileVisibility,
        'is_creator': isCreator ? '1' : '0',
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> getStories(int viewerId) async {
    final response = await crud.postData(
      AppLink.storiesFeed,
      <String, dynamic>{'viewer_id': '$viewerId'},
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> createStory({
    required int userId,
    required String storyText,
    XFile? mediaFile,
    String backgroundColor = '#111111',
    int expiresHours = 24,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(AppLink.storiesCreate));

    final String resolvedStoryType = _resolveStoryType(mediaFile);

    request.fields.addAll(<String, String>{
      'user_id': '$userId',
      'story_type': resolvedStoryType,
      'story_text': storyText,
      'background_color': backgroundColor,
      'expires_hours': '$expiresHours',
    });

    if (mediaFile != null) {
      final String fileName =
          mediaFile.name.trim().isNotEmpty ? mediaFile.name.trim() : 'story.jpg';

      if (mediaFile.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            mediaFile.path,
            filename: fileName,
          ),
        );
      } else {
        final List<int> bytes = await mediaFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );
      }
    }

    return _sendMultipart(request);
  }

  Future<Map<String, dynamic>> markStoryViewed({
    required int storyId,
    required int viewerId,
  }) async {
    final response = await crud.postData(
      AppLink.storiesView,
      <String, dynamic>{
        'story_id': '$storyId',
        'viewer_user_id': '$viewerId',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> reactToStory({
    required int storyId,
    required int userId,
    String reactionType = 'like',
  }) async {
    final response = await crud.postData(
      AppLink.storiesReact,
      <String, dynamic>{
        'story_id': '$storyId',
        'user_id': '$userId',
        'reaction_type': reactionType,
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> getStoryViewers({
    required int storyId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.storiesViewers,
      <String, dynamic>{
        'story_id': '$storyId',
        'user_id': '$userId',
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> sendStoryComment({
    required int storyId,
    required int userId,
    required String commentText,
  }) async {
    final response = await crud.postData(
      AppLink.storiesComment,
      <String, dynamic>{
        'story_id': '$storyId',
        'user_id': '$userId',
        'comment_text': commentText,
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({
    required int viewerId,
    String mode = 'feed',
    int? userId,
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsFeed,
      <String, dynamic>{
        'viewer_id': '$viewerId',
        'mode': mode,
        'user_id': '${userId ?? 0}',
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> togglePostLike({
    required int postId,
    required int userId,
    String reactionType = 'like',
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsToggleLike,
      <String, dynamic>{
        'post_id': '$postId',
        'user_id': '$userId',
        'reaction_type': reactionType,
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> createCustomPerfumePost({
    required int userId,
    required int customPerfumeId,
    required String postText,
    XFile? imageFile,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(AppLink.communityPostsCreate));

    request.fields.addAll(<String, String>{
      'user_id': '$userId',
      'post_text': postText,
      'post_type': 'custom_perfume',
      'related_custom_perfume_id': '$customPerfumeId',
      'is_public': '1',
    });

    if (imageFile != null) {
      final String fileName =
          imageFile.name.trim().isNotEmpty ? imageFile.name.trim() : 'post.jpg';

      if (imageFile.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imageFile.path,
            filename: fileName,
          ),
        );
      } else {
        final List<int> bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );
      }
    }

    return _sendMultipart(request);
  }

  String _resolveStoryType(XFile? mediaFile) {
    if (mediaFile == null) {
      return 'text';
    }

    return _isVideoFile(mediaFile) ? 'video' : 'image';
  }

  Future<Map<String, dynamic>> createCommunityPost({
    required int userId,
    required String postText,
    String postType = 'text',
    List<XFile> mediaFiles = const <XFile>[],
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(AppLink.communityPostsCreate));

    String resolvedPostType = postType;
    if (mediaFiles.isNotEmpty) {
      final bool hasVideo = mediaFiles.any(_isVideoFile);
      final bool hasImage = mediaFiles.any((XFile file) => !_isVideoFile(file));
      if (hasVideo) {
        resolvedPostType = 'video';
      } else if (hasImage && mediaFiles.length > 1) {
        resolvedPostType = 'gallery';
      } else if (hasImage) {
        resolvedPostType = 'image';
      }
    }

    request.fields.addAll(<String, String>{
      'user_id': '$userId',
      'post_text': postText,
      'post_type': resolvedPostType,
      'is_public': '1',
    });

    for (int i = 0; i < mediaFiles.length; i++) {
      final XFile mediaFile = mediaFiles[i];
      final String fileName =
          mediaFile.name.trim().isNotEmpty ? mediaFile.name.trim() : 'post_$i';

      if (mediaFile.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file_$i',
            mediaFile.path,
            filename: fileName,
          ),
        );
      } else {
        final List<int> bytes = await mediaFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'file_$i',
            bytes,
            filename: fileName,
          ),
        );
      }
    }

    return _sendMultipart(request);
  }

  Future<List<Map<String, dynamic>>> getPostComments(int postId) async {
    final response = await crud.postData(
      AppLink.communityPostsComments,
      <String, dynamic>{'post_id': '$postId'},
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> addPostComment({
    required int postId,
    required int userId,
    required String commentText,
    int? parentCommentId,
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsAddComment,
      <String, dynamic>{
        'post_id': '$postId',
        'user_id': '$userId',
        'comment_text': commentText,
        'parent_comment_id': '${parentCommentId ?? ''}',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> deletePost({
    required int postId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsDelete,
      <String, dynamic>{
        'post_id': '$postId',
        'user_id': '$userId',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> deletePostComment({
    required int commentId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsDeleteComment,
      <String, dynamic>{
        'comment_id': '$commentId',
        'user_id': '$userId',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> getPostInteractions({
    required int postId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.communityPostsInteractions,
      <String, dynamic>{
        'post_id': '$postId',
        'user_id': '$userId',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> createCustomPerfumeStory({
    required int userId,
    required String storyText,
    XFile? imageFile,
  }) async {
    return createStory(
      userId: userId,
      storyText: storyText,
      mediaFile: imageFile,
    );
  }

  Future<List<Map<String, dynamic>>> getSavedPerfumes(int userId) async {
    final response = await crud.postData(
      AppLink.savedPerfumesList,
      <String, dynamic>{'user_id': '$userId'},
    );
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getCustomPerfumes({
    required int viewerId,
    String mode = 'mine',
    int? userId,
  }) async {
    final response = await crud.postData(
      AppLink.customPerfumesList,
      <String, dynamic>{
        'viewer_id': '$viewerId',
        'mode': mode,
        'user_id': '${userId ?? 0}',
      },
    );
    return _extractList(response);
  }

  Future<List<Map<String, dynamic>>> getFollowList({
    required int userId,
    required int viewerId,
    String mode = 'followers',
  }) async {
    final response = await crud.postData(
      AppLink.followsList,
      <String, dynamic>{
        'user_id': '$userId',
        'viewer_id': '$viewerId',
        'mode': mode,
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> toggleFollow({
    required int followerUserId,
    required int followedUserId,
  }) async {
    final response = await crud.postData(
      AppLink.followsToggle,
      <String, dynamic>{
        'follower_user_id': '$followerUserId',
        'followed_user_id': '$followedUserId',
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> getConversations(int userId) async {
    final response = await crud.postData(
      AppLink.chatConversationsList,
      <String, dynamic>{'user_id': '$userId'},
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> createConversation({
    required int userOneId,
    required int userTwoId,
  }) async {
    final response = await crud.postData(
      AppLink.chatConversationsCreate,
      <String, dynamic>{
        'user_one_id': '$userOneId',
        'user_two_id': '$userTwoId',
      },
    );
    return _asMap(response);
  }

  Future<List<Map<String, dynamic>>> getConversationMessages({
    required int conversationId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.chatConversationsMessages,
      <String, dynamic>{
        'conversation_id': '$conversationId',
        'user_id': '$userId',
      },
    );
    return _extractList(response);
  }

  Future<Map<String, dynamic>> sendConversationMessage({
    required int conversationId,
    required int senderId,
    required String message,
  }) async {
    final response = await crud.postData(
      AppLink.chatConversationsSend,
      <String, dynamic>{
        'conversation_id': '$conversationId',
        'sender_id': '$senderId',
        'message': message,
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> createReel({
    required int userId,
    required XFile videoFile,
    String? title,
    String? description,
    String visibility = 'public',
    String? tags,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse(AppLink.reelsCreate));

    request.fields.addAll(<String, String>{
      'user_id': '$userId',
      'video_title': (title ?? '').trim(),
      'video_desc': (description ?? '').trim(),
      'video_visibility': visibility,
      'video_tags': (tags ?? '').trim(),
    });

    final String fileName =
        videoFile.name.trim().isNotEmpty ? videoFile.name.trim() : 'reel.mp4';

    if (videoFile.path.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'video_file',
          videoFile.path,
          filename: fileName,
        ),
      );
    } else {
      final List<int> bytes = await videoFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'video_file',
          bytes,
          filename: fileName,
        ),
      );
    }

    return _sendMultipart(request);
  }

  Future<Map<String, dynamic>> deleteReel({
    required int videoId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.reelsDelete,
      <String, dynamic>{
        'video_id': '$videoId',
        'user_id': '$userId',
      },
    );
    return _asMap(response);
  }

  Future<Map<String, dynamic>> getVideoInteractions({
    required int videoId,
    required int userId,
  }) async {
    final response = await crud.postData(
      AppLink.videoInteractions,
      <String, dynamic>{
        'video_id': '$videoId',
        'user_id': '$userId',
      },
    );
    return _asMap(response);
  }

  Map<String, dynamic> _asMap(dynamic response) {
    return response.fold(
      (dynamic l) => <String, dynamic>{'status': 'error', 'failure': l.toString()},
      (dynamic r) => r is Map<String, dynamic>
          ? r
          : Map<String, dynamic>.from(r as Map),
    );
  }

  Future<Map<String, dynamic>> _sendMultipart(http.MultipartRequest request) async {
    try {
      print('Multipart url: ${request.url}');
      print('Multipart fields: ${request.fields}');
      print('Multipart files: ${request.files.map((http.MultipartFile file) => '${file.field}:${file.filename}').toList()}');
      final http.StreamedResponse streamed = await request.send();
      final String body = await streamed.stream.bytesToString();
      print('Multipart response status: ${streamed.statusCode}');
      print('Multipart response body: $body');
      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        return <String, dynamic>{
          'status': 'error',
          'message': 'Request failed with status ${streamed.statusCode}',
          'body': body,
        };
      }
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return _normalizeMultipartResponse(decoded, streamed.statusCode);
      }
      if (decoded is Map) {
        return _normalizeMultipartResponse(
          Map<String, dynamic>.from(decoded),
          streamed.statusCode,
        );
      }
      return <String, dynamic>{'status': 'error', 'message': 'Invalid response'};
    } catch (e) {
      return <String, dynamic>{'status': 'error', 'message': e.toString()};
    }
  }

  Map<String, dynamic> _normalizeMultipartResponse(
    Map<String, dynamic> response,
    int statusCode,
  ) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(response);
    final String status = (normalized['status'] ?? '').toString().trim().toLowerCase();

    if (status == 'success') {
      return normalized;
    }

    if (status == 'ok' || status == 'created') {
      normalized['status'] = 'success';
      return normalized;
    }

    if (status.isEmpty && statusCode >= 200 && statusCode < 300) {
      final String message =
          (normalized['message'] ?? normalized['msg'] ?? '').toString().toLowerCase();
      final bool hasFailureSignal = normalized.containsKey('error') ||
          normalized.containsKey('failure') ||
          message.contains('error') ||
          message.contains('failed');

      if (!hasFailureSignal) {
        normalized['status'] = 'success';
      }
    }

    return normalized;
  }

  List<Map<String, dynamic>> _extractList(dynamic response) {
    final Map<String, dynamic> map = _asMap(response);
    final dynamic data = map['data'];
    if (data is List) {
      return data
          .map((dynamic e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  bool _isVideoFile(XFile file) {
    final String name = file.name.toLowerCase();
    return name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.webm');
  }
}
