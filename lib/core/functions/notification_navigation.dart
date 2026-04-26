import 'package:get/get.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/controler/notification_con.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/view/screen/admin_chats_screen.dart' as chats_screen;
import 'package:tks/view/screen/followers_page.dart';
import 'package:tks/view/screen/fragrance/fragrance_community_screen.dart';
import 'package:tks/view/screen/fragrance/fragrance_story_screen.dart';
import 'package:tks/view/screen/support.dart' as support_screen;
import 'package:tks/view/screen/video_feed_page.dart';

class NotificationNavigation {
  static Future<void> openNotificationItem(AppNotificationItem item) {
    return openFromData(
      payload: item.payload,
      type: item.type,
      refType: item.refType,
      refId: item.refId,
    );
  }

  static Future<void> openFromData({
    required Map<String, dynamic> payload,
    String? type,
    String? refType,
    String? refId,
  }) async {
    final String normalizedType = (type ?? payload['type'] ?? '').toString();
    final String normalizedRefType =
        (refType ?? payload['ref_type'] ?? '').toString();
    final int currentUserId =
        Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;

    if (normalizedType == 'admin_chat') {
      Get.to(() => support_screen.SupportHome(userId: currentUserId));
      return;
    }

    if (normalizedType == 'direct_message' ||
        normalizedRefType == 'conversation') {
      final int? conversationId = _readInt(
        payload['conversation_id'],
        refId,
      );
      final int? actorUserId = _readInt(
        payload['actor_user_id'],
        payload['user_id'],
      );

      Get.to(
        () => chats_screen.SupportHome(
          userId: currentUserId,
          initialConversationId: conversationId,
          initialPeerUserId: actorUserId,
        ),
      );
      return;
    }

    if (normalizedType == 'new_follower' || normalizedRefType == 'follow') {
      final int? followerUserId = _readInt(
        payload['actor_user_id'],
        payload['follower_user_id'],
        payload['user_id'],
        refId,
      );

      Get.to(
        () => FollowersPage(
          userId: currentUserId,
          viewerId: currentUserId,
          mode: 'followers',
          highlightUserId: followerUserId,
        ),
      );
      return;
    }

    if (normalizedType == 'new_story' ||
        normalizedType == 'story_reaction' ||
        normalizedRefType == 'story' ||
        (payload['screen']?.toString() ?? '') == 'stories') {
      await _openStoryNotification(
        payload: payload,
        currentUserId: currentUserId,
        refId: refId,
      );
      return;
    }

    if (normalizedType == 'new_video' ||
        normalizedType == 'new_reel' ||
        normalizedType == 'reel_like' ||
        normalizedType == 'reel_comment' ||
        normalizedType == 'video_like' ||
        normalizedType == 'video_comment' ||
        normalizedType == 'comment_reply' ||
        normalizedType == 'comment_like' ||
        normalizedRefType == 'video' ||
        normalizedRefType == 'video_comment') {
      final int? videoId = _readInt(
        payload['video_id'],
        normalizedRefType == 'video' ? refId : null,
      );
      final int? commentId = _readInt(
        payload['comment_id'],
        normalizedRefType == 'video_comment' ? refId : null,
      );

      Get.to(
        () => VideoFeedPage(
          initialVideoId: videoId,
          openCommentsOnLoad: commentId != null,
          initialCommentId: commentId,
        ),
      );
      return;
    }

    if (normalizedType == 'order_status' ||
        normalizedType == 'payment_status') {
      Get.toNamed(AppRoutes.ordersarchive_page);
      return;
    }

    if (normalizedType == 'new_post' ||
        normalizedType == 'post_like' ||
        normalizedType == 'post_comment' ||
        normalizedRefType == 'post') {
      final int? postId = _readInt(
        payload['post_id'],
        refId,
      );
      final int initialTab = normalizedType == 'new_post' ? 0 : 1;

      Get.to(
        () => FragranceCommunityScreen(
          initialTab: initialTab,
          targetPostId: postId,
          openCommentsOnLoad: normalizedType == 'post_comment',
        ),
      );
      return;
    }

    if (normalizedType == 'new_product') {
      Get.toNamed(AppRoutes.homepage);
      return;
    }

    Get.toNamed(AppRoutes.notificationPage);
  }

  static Future<void> _openStoryNotification({
    required Map<String, dynamic> payload,
    required int currentUserId,
    String? refId,
  }) async {
    if (currentUserId <= 0) {
      Get.toNamed(AppRoutes.homepage);
      return;
    }

    try {
      final socialData = FragranceSocialData(Get.find<Crud>());
      final stories = await socialData.getStories(currentUserId);
      if (stories.isEmpty) {
        Get.toNamed(AppRoutes.homepage);
        return;
      }

      final int? storyId = _readInt(
        payload['story_id'],
        refId,
      );
      final int? actorUserId = _readInt(
        payload['actor_user_id'],
        payload['user_id'],
      );

      Map<String, dynamic>? targetStory;
      if (storyId != null) {
        for (final story in stories) {
          if (_readInt(story['story_id']) == storyId) {
            targetStory = story;
            break;
          }
        }
      }

      if (targetStory == null && actorUserId != null) {
        for (final story in stories) {
          if (_readInt(story['user_id']) == actorUserId) {
            targetStory = story;
            break;
          }
        }
      }

      targetStory ??= stories.first;
      final Map<String, dynamic> selectedStory = targetStory;

      final int targetUserId =
          _readInt(selectedStory['user_id'], actorUserId, currentUserId) ??
              currentUserId;

      final groupedStories = stories
          .where(
            (story) => _readInt(story['user_id']) == targetUserId,
          )
          .toList();

      final orderedStories = groupedStories.isNotEmpty
          ? groupedStories
          : <Map<String, dynamic>>[selectedStory];

      final int initialIndex = orderedStories.indexWhere(
        (story) =>
            _readInt(story['story_id']) ==
            _readInt(selectedStory['story_id'], storyId),
      );

      Get.to(
        () => FragranceStoryScreen(
          storyId: _readInt(selectedStory['story_id'], storyId) ?? 0,
          viewerId: currentUserId,
          mediaPath: (selectedStory['media_url'] ?? '').toString(),
          userName: _storyUserName(selectedStory),
          storyType: (selectedStory['story_type'] ?? 'image').toString(),
          storyText: (selectedStory['story_text'] ?? '').toString(),
          timeLabel: (selectedStory['created_at'] ?? '').toString(),
          stories: orderedStories,
          initialIndex: initialIndex < 0 ? 0 : initialIndex,
        ),
      );
    } catch (_) {
      Get.toNamed(AppRoutes.homepage);
    }
  }

  static String _storyUserName(Map<String, dynamic> story) {
    final String displayName = (story['display_name'] ?? '').toString().trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final String usersName = (story['users_name'] ?? '').toString().trim();
    if (usersName.isNotEmpty) {
      return usersName;
    }

    final int storyUserId = _readInt(story['user_id']) ?? 0;
    return storyUserId > 0 ? 'User #$storyUserId' : 'Story';
  }

  static int? _readInt(dynamic a, [dynamic b, dynamic c, dynamic d]) {
    for (final dynamic value in <dynamic>[a, b, c, d]) {
      final int? parsed = int.tryParse('${value ?? ''}');
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return null;
  }
}
