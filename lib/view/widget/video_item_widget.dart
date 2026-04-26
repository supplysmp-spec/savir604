import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/video_model.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/data/datasource/remote/video/video_remote.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../controler/video/video_controller.dart';

class VideoItemWidget extends StatefulWidget {
  final VideoModel video;
  final VideoController controller;
  final VoidCallback onOpenComments;
  final VoidCallback onDelete;
  final VoidCallback onOpenInsights;
  final bool isActive;
  final double topInset;
  final double bottomInset;

  const VideoItemWidget({
    super.key,
    required this.video,
    required this.controller,
    required this.onOpenComments,
    required this.onDelete,
    required this.onOpenInsights,
    required this.isActive,
    this.topInset = 70,
    this.bottomInset = 18,
  });

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget>
    with WidgetsBindingObserver {
  static const String _publicSiteUrl =
      'https://percious-fragance.savir-technology.com/';
  late final FragranceSocialData _socialData;
  late final VideoRemote _videoRemote;
  late final int currentUserId;

  VideoPlayerController? _vc;
  bool _videoFailed = false;
  bool _showPauseIcon = false;
  bool _isLoadingCommentCount = false;
  bool _isFollowLoading = false;
  int? _commentCount;
  Map<String, dynamic>? _creatorProfile;
  final List<_HeartBurst> _heartBursts = <_HeartBurst>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _socialData = FragranceSocialData(Get.find<Crud>());
    _videoRemote = VideoRemote(Get.find<Crud>());
    currentUserId = Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
    _init();
    _loadVideoMetadata();
  }

  @override
  void didUpdateWidget(covariant VideoItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.video.videoId != widget.video.videoId) {
      _creatorProfile = null;
      _commentCount = null;
      _loadVideoMetadata();
      _init();
    }

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        widget.controller.play(widget.video.videoId);
      } else {
        widget.controller.pause(widget.video.videoId);
      }
    }
  }

  Future<void> _init() async {
    try {
      await widget.controller.initVideoPlayer(widget.video);
      _vc = widget.controller.getController(widget.video.videoId);

      if (_vc != null && _vc!.value.isInitialized) {
        if (!mounted) return;
        setState(() => _videoFailed = false);
        if (widget.isActive) {
          widget.controller.play(widget.video.videoId);
          widget.controller.markView(widget.video, currentUserId);
        }
      } else {
        if (!mounted) return;
        setState(() {
          _videoFailed =
              widget.controller.failedVideoIds.contains(widget.video.videoId);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _videoFailed = true);
    }
  }

  Future<void> _loadVideoMetadata() async {
    await Future.wait<void>(<Future<void>>[
      _loadCommentCount(),
      _loadCreatorProfile(),
    ]);
  }

  Future<void> _loadCommentCount() async {
    if (_isLoadingCommentCount) return;
    if (mounted) {
      setState(() => _isLoadingCommentCount = true);
    }
    try {
      final comments =
          await _videoRemote.getComments(videoId: widget.video.videoId);
      if (!mounted) return;
      setState(() => _commentCount = comments.length);
    } catch (_) {
      if (!mounted) return;
      setState(() => _commentCount = 0);
    } finally {
      if (mounted) {
        setState(() => _isLoadingCommentCount = false);
      }
    }
  }

  Future<void> _loadCreatorProfile() async {
    final int creatorId = widget.video.videoUserId ?? 0;
    if (creatorId <= 0) return;

    try {
      final response = await _socialData.getProfile(
        userId: creatorId,
        viewerId: currentUserId > 0 ? currentUserId : creatorId,
      );
      final dynamic data = response['data'];
      if (!mounted || data is! Map) return;
      setState(() {
        _creatorProfile = Map<String, dynamic>.from(data);
      });
    } catch (_) {}
  }

  Future<void> _toggleFollowCreator() async {
    final int creatorId = widget.video.videoUserId ?? 0;
    if (_isFollowLoading ||
        creatorId <= 0 ||
        creatorId == currentUserId ||
        currentUserId <= 0) {
      return;
    }

    setState(() => _isFollowLoading = true);
    try {
      final response = await _socialData.toggleFollow(
        followerUserId: currentUserId,
        followedUserId: creatorId,
      );
      if (!mounted) return;
      setState(() {
        _creatorProfile = <String, dynamic>{
          ...?_creatorProfile,
          'is_following': (response['action'] ?? '') == 'followed' ? 1 : 0,
        };
      });
    } finally {
      if (mounted) {
        setState(() => _isFollowLoading = false);
      }
    }
  }

  void _openCreatorProfile() {
    final int creatorId = widget.video.videoUserId ?? 0;
    if (creatorId <= 0) return;
    Get.to(() => ProfilePage(userId: creatorId));
  }

  Future<void> _shareVideo() async {
    final List<String> parts = <String>[
      '$_creatorName shared a reel on Savir.',
      _videoTitle,
      _videoCaption,
      _publicSiteUrl,
    ];

    await Share.share(
      parts.where((String item) => item.trim().isNotEmpty).join('\n\n'),
      subject: '$_creatorName on Savir Reels',
    );
  }

  Future<void> _showMoreSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if ((widget.video.videoUserId ?? 0) > 0)
                  _MoreSheetAction(
                    icon: Icons.person_outline_rounded,
                    label: 'Open profile',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openCreatorProfile();
                    },
                  ),
                _MoreSheetAction(
                  icon: Icons.copy_all_rounded,
                  label: 'Copy video link',
                  onTap: () async {
                    final ScaffoldMessengerState messenger =
                        ScaffoldMessenger.of(context);
                    Navigator.of(sheetContext).pop();
                    await Clipboard.setData(
                      ClipboardData(text: widget.video.videoUrl),
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Video link copied.')),
                    );
                  },
                ),
                _MoreSheetAction(
                  icon: Icons.share_outlined,
                  label: 'Share reel',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _shareVideo();
                  },
                ),
                if (_isOwnVideo)
                  _MoreSheetAction(
                    icon: Icons.insights_outlined,
                    label: 'View activity',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onOpenInsights();
                    },
                  ),
                if (_isOwnVideo)
                  _MoreSheetAction(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete reel',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onDelete();
                    },
                  ),
                _MoreSheetAction(
                  icon: Icons.open_in_new_rounded,
                  label: 'Open video externally',
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await launchUrl(
                      Uri.parse(widget.video.videoUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _creatorName {
    final String profileName =
        (_creatorProfile?['display_name'] ?? '').toString().trim();
    if (profileName.isNotEmpty) return profileName;
    final String fallbackName = widget.video.uploaderName?.trim() ?? '';
    return fallbackName.isNotEmpty ? fallbackName : 'Creator';
  }

  String get _videoTitle {
    final String title = widget.video.videoTitle?.trim() ?? '';
    if (title.isNotEmpty) return title;
    final String product = widget.video.productNameAr?.trim() ?? '';
    return product.isNotEmpty ? product : 'Fragrance Reel';
  }

  String get _videoCaption {
    final String caption = widget.video.videoDesc?.trim() ?? '';
    return caption.isNotEmpty ? caption : 'Watch this fragrance reel on Savir.';
  }

  bool get _isOwnVideo => (widget.video.videoUserId ?? 0) == currentUserId;

  bool get _isFollowingCreator =>
      '${_creatorProfile?['is_following'] ?? 0}' == '1';

  String get _videoDateLabel {
    final String raw = (widget.video.videoDate ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  List<String> get _creatorAvatarUrls => AppImageUrls.profileAvatar(
        avatarUrl: (_creatorProfile?['profile_image_url'] ??
                _creatorProfile?['avatar_url'])
            .toString(),
        imagePath: (_creatorProfile?['users_image'] ?? '').toString(),
      );

  void _togglePlayback() {
    if (_vc == null || _videoFailed) return;
    if (_vc!.value.isPlaying) {
      widget.controller.pause(widget.video.videoId);
      setState(() => _showPauseIcon = true);
    } else {
      widget.controller.play(widget.video.videoId);
      setState(() => _showPauseIcon = false);
    }
  }

  Future<void> _handleLikeTap() async {
    final bool? isLiked =
        await widget.controller.toggleLike(widget.video, currentUserId);
    if (!mounted || isLiked != true) return;
    _spawnHeartBurst();
  }

  void _spawnHeartBurst() {
    final int seed = DateTime.now().microsecondsSinceEpoch;
    final List<_HeartBurst> hearts = List<_HeartBurst>.generate(6, (int index) {
      final double spread = (index - 2.5) * 18;
      return _HeartBurst(
        key: ValueKey<int>(seed + index),
        leftOffset: spread,
        size: 18 + (index % 3) * 6,
        duration: Duration(milliseconds: 900 + (index * 70)),
      );
    });

    setState(() => _heartBursts.addAll(hearts));

    for (final _HeartBurst burst in hearts) {
      Future<void>.delayed(burst.duration, () {
        if (!mounted) return;
        setState(() => _heartBursts.remove(burst));
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_vc == null || _videoFailed) return;
    if (state == AppLifecycleState.paused) {
      widget.controller.pause(widget.video.videoId);
    } else if (state == AppLifecycleState.resumed && widget.isActive) {
      widget.controller.play(widget.video.videoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool compactWidth = screenSize.width < 410;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: _togglePlayback,
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Center(child: _buildMedia()),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xB0120E09),
                        Color(0x33000000),
                        Color(0xE6110F0B),
                      ],
                      stops: <double>[0.0, 0.45, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.9, -0.88),
                        radius: 1.4,
                        colors: <Color>[
                          const Color(0xFFD6B878).withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              widget.topInset,
              16,
              widget.bottomInset,
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double availableHeight = constraints.maxHeight;
                final bool compactHeight = availableHeight < 560;
                final bool compactLayout = compactHeight || compactWidth;
                final double railWidth = compactLayout ? 72 : 88;
                final double panelMaxHeight = compactHeight
                    ? availableHeight * 0.52
                    : availableHeight * 0.42;

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: availableHeight),
                    child: SingleChildScrollView(
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxHeight: panelMaxHeight),
                              child: _buildInfoPanel(
                                compactHeight: compactHeight,
                                compactWidth: compactWidth,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _VideoActionsRail(
                            video: widget.video,
                            controller: widget.controller,
                            onOpenComments: widget.onOpenComments,
                            onShare: _shareVideo,
                            onMore: _showMoreSheet,
                            onLike: _handleLikeTap,
                            currentUserId: currentUserId,
                            commentCount: _commentCount,
                            isLoadingCommentCount: _isLoadingCommentCount,
                            compact: compactLayout,
                            width: railWidth,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        IgnorePointer(
          ignoring: !_showPauseIcon,
          child: AnimatedOpacity(
            opacity: _showPauseIcon ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 44,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Stack(
            children: _heartBursts
                .map(
                  (_HeartBurst burst) => _FloatingHeart(
                    key: burst.key,
                    leftOffset: burst.leftOffset,
                    size: burst.size,
                    duration: burst.duration,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel({
    required bool compactHeight,
    required bool compactWidth,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        right: compactWidth ? 6 : 12,
        bottom: compactHeight ? 4 : 10,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: _openCreatorProfile,
              borderRadius: BorderRadius.circular(999),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _buildCreatorAvatar(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _creatorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compactHeight ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            shadows: const <Shadow>[
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            Text(
                              _videoTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: compactHeight ? 12 : 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_videoDateLabel.isNotEmpty) ...<Widget>[
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white70,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _videoDateLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.74),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_isOwnVideo && (widget.video.videoUserId ?? 0) > 0) ...<Widget>[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed:
                          _isFollowLoading ? null : _toggleFollowCreator,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.74),
                        ),
                        backgroundColor: Colors.black.withValues(alpha: 0.18),
                        padding: EdgeInsets.symmetric(
                          horizontal: compactWidth ? 10 : 14,
                          vertical: compactHeight ? 8 : 10,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        _isFollowLoading
                            ? '...'
                            : (_isFollowingCreator ? 'Following' : 'Follow'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: compactWidth ? 11 : 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: compactHeight ? 10 : 12),
            Text(
              _videoCaption,
              maxLines: compactHeight ? 3 : 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compactHeight ? 14 : 15,
                height: 1.4,
                shadows: const <Shadow>[
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            if ((widget.video.productNameAr ?? '').trim().isNotEmpty) ...<Widget>[
              SizedBox(height: compactHeight ? 8 : 10),
              Text(
                '# ${widget.video.productNameAr!.trim()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFFE7D39B),
                  fontSize: compactHeight ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  shadows: const <Shadow>[
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: compactHeight ? 10 : 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: <Widget>[
                _MetaPill(
                  icon: Icons.visibility_outlined,
                  label: _compactCount(widget.video.videoViews),
                  compact: compactHeight,
                ),
                _MetaPill(
                  icon: Icons.favorite_outline_rounded,
                  label: _compactCount(widget.video.videoLikes),
                  compact: compactHeight,
                ),
                if (_commentCount != null)
                  _MetaPill(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: _compactCount(_commentCount!),
                    compact: compactHeight,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorAvatar() {
    if (_creatorAvatarUrls.isNotEmpty) {
      return ClipOval(
        child: FallbackNetworkImage(
          imageUrls: _creatorAvatarUrls,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          label: _creatorName,
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.74),
          width: 1.2,
        ),
        color: Colors.black.withValues(alpha: 0.20),
      ),
      alignment: Alignment.center,
      child: Text(
        _creatorName.substring(0, 1).toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (_videoFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.video_file_outlined,
              size: 64,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              'video_inline_not_supported'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            if (kIsWeb)
              FilledButton.icon(
                onPressed: () async {
                  final Uri uri = Uri.parse(widget.video.videoUrl);
                  await launchUrl(uri, webOnlyWindowName: '_blank');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text('open_video'.tr),
              )
            else
              Text(
                widget.video.videoUrl,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      );
    }

    if (_vc != null && _vc!.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _vc!.value.size.width,
          height: _vc!.value.size.height,
          child: VideoPlayer(_vc!),
        ),
      );
    }

    if (widget.video.videoThumbnail != null &&
        widget.video.videoThumbnail!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.video.videoThumbnail!,
        fit: BoxFit.cover,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 12),
        Text(
          'loading_video'.tr,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _VideoActionsRail extends StatelessWidget {
  final VideoModel video;
  final VideoController controller;
  final Future<void> Function() onLike;
  final VoidCallback onOpenComments;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final int currentUserId;
  final int? commentCount;
  final bool isLoadingCommentCount;
  final bool compact;
  final double width;

  const _VideoActionsRail({
    required this.video,
    required this.controller,
    required this.onLike,
    required this.onOpenComments,
    required this.onShare,
    required this.onMore,
    required this.currentUserId,
    required this.commentCount,
    required this.isLoadingCommentCount,
    required this.compact,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final VideoModel current = controller.videos.firstWhere(
        (VideoModel item) => item.videoId == video.videoId,
      );

      return Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _RailAction(
              icon: current.isLiked
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: 'Like',
              count: _compactCount(current.videoLikes),
              onTap: () {
                onLike();
              },
              iconColor:
                  current.isLiked ? const Color(0xFFD6B878) : Colors.white,
              compact: compact,
            ),
            SizedBox(height: compact ? 10 : 12),
            _RailAction(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: Colors.white,
              label: 'Reply',
              count: isLoadingCommentCount
                  ? '...'
                  : _compactCount(commentCount ?? 0),
              onTap: onOpenComments,
              compact: compact,
            ),
            SizedBox(height: compact ? 10 : 12),
            _RailAction(
              icon: Icons.share_outlined,
              iconColor: Colors.white,
              label: 'Share',
              count: '',
              onTap: onShare,
              compact: compact,
            ),
            SizedBox(height: compact ? 10 : 12),
            _RailAction(
              icon: Icons.more_horiz_rounded,
              iconColor: Colors.white,
              label: 'More',
              count: '',
              onTap: onMore,
              compact: compact,
            ),
          ],
        ),
      );
    });
  }
}

class _RailAction extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String count;
  final VoidCallback onTap;
  final bool compact;

  const _RailAction({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.count,
    required this.onTap,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: iconColor,
              size: compact ? 26 : 30,
            ),
            SizedBox(height: compact ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 10 : 11,
                shadows: const <Shadow>[
                  Shadow(
                    color: Colors.black87,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            if (count.isNotEmpty) ...<Widget>[
              SizedBox(height: compact ? 3 : 4),
              Text(
                count,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 11 : 12,
                  shadows: const <Shadow>[
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: compact ? 14 : 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              shadows: const <Shadow>[
                Shadow(
                  color: Colors.black87,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBurst {
  const _HeartBurst({
    required this.key,
    required this.leftOffset,
    required this.size,
    required this.duration,
  });

  final ValueKey<int> key;
  final double leftOffset;
  final double size;
  final Duration duration;
}

class _FloatingHeart extends StatelessWidget {
  const _FloatingHeart({
    super.key,
    required this.leftOffset,
    required this.size,
    required this.duration,
  });

  final double leftOffset;
  final double size;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: duration,
        builder: (BuildContext context, double value, Widget? child) {
          final double dx = leftOffset * value;
          final double dy = -150 * value;
          final double opacity = (1 - value).clamp(0, 1);
          final double scale = 0.8 + (0.6 * value);

          return Align(
            alignment: const Alignment(0, 0.28),
            child: Transform.translate(
              offset: Offset(dx, dy),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFD6B878),
                    size: size,
                    shadows: const <Shadow>[
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MoreSheetAction extends StatelessWidget {
  const _MoreSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A17),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: const Color(0xFFD6B878)),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _compactCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(value % 1000 == 0 ? 0 : 1)}K';
  }
  return '$value';
}
