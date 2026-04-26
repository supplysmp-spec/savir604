import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/video/comments_controller.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/screen/comment_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';
import 'package:tks/view/widget/video_item_widget.dart';

import '../../controler/video/video_controller.dart';
import '../../data/datasource/model/video_model.dart';

class VideoFeedPage extends StatefulWidget {
  final int initialIndex;
  final int? initialVideoId;
  final bool openCommentsOnLoad;
  final int? initialCommentId;

  const VideoFeedPage({
    super.key,
    this.initialIndex = 0,
    this.initialVideoId,
    this.openCommentsOnLoad = false,
    this.initialCommentId,
  });

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late final VideoController controller;
  late final PageController pageController;
  late final FragranceSocialData _socialData;
  Worker? _videosWorker;
  bool _didResolveInitialTarget = false;
  bool _didOpenInitialComments = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VideoController(Crud()));
    _socialData = FragranceSocialData(Get.find<Crud>());
    pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setCurrentIndex(widget.initialIndex);
      _tryResolveInitialTarget();
    });
    _videosWorker = ever<List<VideoModel>>(controller.videos, (_) {
      _tryResolveInitialTarget();
    });
  }

  @override
  void dispose() {
    _videosWorker?.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppSurfacePalette palette = AppSurfacePalette.of(context);
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.screenGradient,
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF151311).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF3B3125)),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFFD6B878),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Preparing your reel gallery...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (controller.videos.isEmpty) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.screenGradient,
              ),
            ),
            child: Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF151311).withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF3B3125)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD6B878).withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.video_collection_outlined,
                        color: Color(0xFFD6B878),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Reels will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'no_videos_available'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.68),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Stack(
          children: <Widget>[
            PageView.builder(
              controller: pageController,
              scrollDirection: Axis.vertical,
              itemCount: controller.videos.length,
              onPageChanged: controller.setCurrentIndex,
              itemBuilder: (BuildContext context, int index) {
                final video = controller.videos[index];
                return VideoItemWidget(
                  video: video,
                  controller: controller,
                  isActive: controller.currentIndex.value == index,
                  topInset: 116,
                  bottomInset: 24,
                  onOpenComments: () {
                    final int currentUserId =
                        Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
                    Get.bottomSheet(
                      CommentsPage(videoId: video.videoId, userId: currentUserId),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    ).whenComplete(() {
                      try {
                        Get.delete<CommentsController>(tag: 'comments_${video.videoId}');
                      } catch (_) {}
                    });
                  },
                  onDelete: () => _deleteVideo(video),
                  onOpenInsights: () => _openVideoInsights(video),
                );
              },
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SafeArea(
                bottom: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12100D).withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: const Color(0xFF3B3125)),
                  ),
                  child: Row(
                    children: <Widget>[
                      InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            const Text(
                              'Precious Reels',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Curated fragrance stories',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.62),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD6B878).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFD6B878).withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          '${controller.currentIndex.value + 1}/${controller.videos.length}',
                          style: const TextStyle(
                            color: Color(0xFFEAD7AB),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _tryResolveInitialTarget() {
    if (!mounted || controller.videos.isEmpty) {
      return;
    }

    if (!_didResolveInitialTarget && widget.initialVideoId != null) {
      final int targetIndex = controller.videos.indexWhere(
        (VideoModel video) => video.videoId == widget.initialVideoId,
      );
      if (targetIndex >= 0) {
        _didResolveInitialTarget = true;
        if (pageController.hasClients) {
          pageController.jumpToPage(targetIndex);
        }
        controller.setCurrentIndex(targetIndex);
      }
    }

    if (widget.openCommentsOnLoad && !_didOpenInitialComments) {
      final int index =
          controller.currentIndex.value.clamp(0, controller.videos.length - 1) as int;
      final VideoModel video = controller.videos[index];
      _didOpenInitialComments = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openCommentsForVideo(video.videoId);
      });
    }
  }

  void _openCommentsForVideo(int videoId) {
    final int currentUserId =
        Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
    Get.bottomSheet(
      CommentsPage(videoId: videoId, userId: currentUserId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      try {
        Get.delete<CommentsController>(tag: 'comments_$videoId');
      } catch (_) {}
    });
  }

  Future<void> _deleteVideo(VideoModel video) async {
    final int currentUserId =
        Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
    if (currentUserId <= 0) {
      return;
    }

    final response = await _socialData.deleteReel(
      videoId: video.videoId,
      userId: currentUserId,
    );

    if (!mounted) return;
    if ((response['status'] ?? '') == 'success') {
      controller.videos.removeWhere((item) => item.videoId == video.videoId);
      if (controller.currentIndex.value >= controller.videos.length &&
          controller.videos.isNotEmpty) {
        controller.setCurrentIndex(controller.videos.length - 1);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel deleted successfully.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (response['message'] ?? 'Unable to delete reel.').toString(),
        ),
      ),
    );
  }

  Future<void> _openVideoInsights(VideoModel video) async {
    final int currentUserId =
        Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
    if (currentUserId <= 0 || (video.videoUserId ?? 0) != currentUserId) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.getVideoInteractions(
      videoId: video.videoId,
      userId: currentUserId,
    );

    if (!mounted) return;
    if ((response['status'] ?? '') != 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (response['message'] ?? 'Unable to load reel activity.').toString(),
          ),
        ),
      );
      return;
    }

    final List<Map<String, dynamic>> viewers =
        ((response['viewers'] as List?) ?? <dynamic>[])
            .map((dynamic item) => Map<String, dynamic>.from(item as Map))
            .toList();
    final List<Map<String, dynamic>> likes =
        ((response['likes'] as List?) ?? <dynamic>[])
            .map((dynamic item) => Map<String, dynamic>.from(item as Map))
            .toList();
    final List<Map<String, dynamic>> comments =
        ((response['comments'] as List?) ?? <dynamic>[])
            .map((dynamic item) => Map<String, dynamic>.from(item as Map))
            .toList();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Reel Activity',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _buildSummaryChip('Viewers', viewers.length),
                      _buildSummaryChip('Likes', likes.length),
                      _buildSummaryChip('Comments', comments.length),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildActivitySection(
                    title: 'Viewers',
                    emptyLabel: 'No viewers yet.',
                    items: viewers,
                    subtitleBuilder: (_) => 'Viewed your reel',
                    timeKey: 'viewed_at',
                  ),
                  _buildActivitySection(
                    title: 'Likes',
                    emptyLabel: 'No likes yet.',
                    items: likes,
                    subtitleBuilder: (_) => 'Liked your reel',
                    timeKey: 'like_date',
                  ),
                  _buildActivitySection(
                    title: 'Comments',
                    emptyLabel: 'No comments yet.',
                    items: comments,
                    subtitleBuilder: (Map<String, dynamic> item) =>
                        (item['comment_text'] ?? '').toString(),
                    timeKey: 'comment_date',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryChip(String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A17),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Text(
        '$label: $count',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildActivitySection({
    required String title,
    required String emptyLabel,
    required List<Map<String, dynamic>> items,
    required String Function(Map<String, dynamic>) subtitleBuilder,
    required String timeKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A17),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$title (${items.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                emptyLabel,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
              )
            else
              ...items.map((Map<String, dynamic> item) {
                final int userId = int.tryParse('${item['user_id'] ?? 0}') ?? 0;
                final String displayName =
                    (item['display_name'] ?? item['users_name'] ?? 'Member')
                        .toString();
                final String subtitle = subtitleBuilder(item).trim();
                final String rawTime = (item[timeKey] ?? '').toString().trim();
                final String timeLabel = rawTime.length >= 16
                    ? rawTime.substring(0, 16).replaceFirst('T', ' ')
                    : rawTime;
                final List<String> imageUrls = AppImageUrls.profileAvatar(
                  avatarUrl:
                      (item['profile_image_url'] ?? item['avatar_url']).toString(),
                  imagePath: (item['users_image'] ?? '').toString(),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: userId > 0
                        ? () {
                            Get.back();
                            Get.to(() => ProfilePage(userId: userId));
                          }
                        : null,
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2A2722),
                      child: ClipOval(
                        child: FallbackNetworkImage(
                          imageUrls: imageUrls,
                          label: displayName,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.74),
                            ),
                          ),
                        if (timeLabel.isNotEmpty)
                          Text(
                            timeLabel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.54),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: userId > 0
                        ? const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFFD6B878),
                          )
                        : null,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
