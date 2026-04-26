import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class FragranceStoryScreen extends StatefulWidget {
  const FragranceStoryScreen({
    super.key,
    required this.storyId,
    required this.viewerId,
    required this.mediaPath,
    required this.userName,
    this.storyType = 'image',
    this.storyText = '',
    this.timeLabel = '3h ago',
    this.stories = const <Map<String, dynamic>>[],
    this.initialIndex = 0,
  });

  final int storyId;
  final int viewerId;
  final String mediaPath;
  final String userName;
  final String storyType;
  final String storyText;
  final String timeLabel;
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  @override
  State<FragranceStoryScreen> createState() => _FragranceStoryScreenState();
}

class _FragranceStoryScreenState extends State<FragranceStoryScreen>
    with SingleTickerProviderStateMixin {
  late final FragranceSocialData _socialData;
  late final AnimationController _progressController;
  final TextEditingController _commentController = TextEditingController();

  bool _reactionSent = false;
  bool _isSendingComment = false;
  bool _isLoadingViewers = false;
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoError = false;
  late int _currentIndex;

  List<Map<String, dynamic>> get _stories =>
      widget.stories.isNotEmpty ? widget.stories : <Map<String, dynamic>>[_legacyStory];

  Map<String, dynamic> get _legacyStory => <String, dynamic>{
        'story_id': widget.storyId,
        'user_id': widget.viewerId,
        'media_url': widget.mediaPath,
        'users_name': widget.userName,
        'display_name': widget.userName,
        'story_type': widget.storyType,
        'story_text': widget.storyText,
        'created_at': widget.timeLabel,
      };

  Map<String, dynamic> get _currentStory => _stories[_currentIndex];

  String get _currentUserName {
    final String displayName =
        (_currentStory['display_name'] ?? '').toString().trim();
    final String userName = (_currentStory['users_name'] ?? '').toString().trim();
    if (displayName.isNotEmpty) return displayName;
    if (userName.isNotEmpty) return userName;
    return widget.userName;
  }

  String get _currentMediaPath =>
      (_currentStory['media_url'] ?? '').toString().trim();

  String get _currentStoryType =>
      (_currentStory['story_type'] ?? widget.storyType).toString().trim().toLowerCase();

  String get _currentStoryText =>
      (_currentStory['story_text'] ?? '').toString();

  int get _currentStoryId =>
      int.tryParse('${_currentStory['story_id']}') ?? widget.storyId;

  int get _currentStoryOwnerId =>
      int.tryParse('${_currentStory['user_id']}') ?? 0;

  bool get _isOwnStory => _currentStoryOwnerId == widget.viewerId;

  int get _currentViewsCount =>
      int.tryParse('${_currentStory['views_count']}') ?? 0;

  String get _currentTimeLabel {
    final String createdAt = (_currentStory['created_at'] ?? '').toString().trim();
    if (createdAt.isEmpty) {
      return widget.timeLabel;
    }
    if (createdAt.length >= 16) {
      return createdAt.substring(0, 16).replaceFirst('T', ' ');
    }
    return createdAt;
  }

  bool get _isVideo =>
      _currentStoryType == 'video' && _currentMediaPath.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _currentIndex = widget.initialIndex.clamp(0, _stories.length - 1);
    _progressController = AnimationController(vsync: this)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _goToNextStory();
        }
      });
    _loadCurrentStory();
  }

  Future<void> _loadCurrentStory() async {
    _progressController.stop();
    _progressController.reset();
    _reactionSent = false;
    await _disposeVideoController();
    if (!mounted) return;
    setState(() {
      _videoReady = false;
      _videoError = false;
    });
    await _markViewed();
    if (_isVideo) {
      await _initVideoIfNeeded();
    } else {
      _startProgress(const Duration(seconds: 5));
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _startProgress(Duration duration) {
    final Duration safeDuration =
        duration.inMilliseconds <= 0 ? const Duration(seconds: 5) : duration;
    _progressController.duration = safeDuration;
    _progressController.forward(from: 0);
  }

  Future<void> _markViewed() async {
    if (_currentStoryId <= 0 || widget.viewerId <= 0 || _isOwnStory) {
      return;
    }
    await _socialData.markStoryViewed(
      storyId: _currentStoryId,
      viewerId: widget.viewerId,
    );
    _currentStory['is_viewed'] = 1;
  }

  Future<void> _reactToStory() async {
    if (_reactionSent || _currentStoryId <= 0 || widget.viewerId <= 0 || _isOwnStory) {
      return;
    }
    final Map<String, dynamic> response = await _socialData.reactToStory(
      storyId: _currentStoryId,
      userId: widget.viewerId,
    );
    if (!mounted) return;
    if ((response['status'] ?? '') == 'success') {
      setState(() => _reactionSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Story reaction sent')),
      );
    }
  }

  Future<void> _sendStoryComment() async {
    final String comment = _commentController.text.trim();
    if (comment.isEmpty || _isSendingComment || _isOwnStory || _currentStoryId <= 0) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSendingComment = true);
    final Map<String, dynamic> response = await _socialData.sendStoryComment(
      storyId: _currentStoryId,
      userId: widget.viewerId,
      commentText: comment,
    );
    if (!mounted) return;
    setState(() => _isSendingComment = false);

    if ((response['status'] ?? '') == 'success') {
      _commentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your reply was sent to chat')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((response['message'] ?? 'Unable to send story reply').toString()),
      ),
    );
  }

  Future<void> _showViewersSheet() async {
    if (_isLoadingViewers || !_isOwnStory || _currentStoryId <= 0) {
      return;
    }

    setState(() => _isLoadingViewers = true);
    final List<Map<String, dynamic>> viewers = await _socialData.getStoryViewers(
      storyId: _currentStoryId,
      userId: widget.viewerId,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingViewers = false;
      _currentStory['views_count'] = viewers.length;
    });

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Icon(Icons.remove_red_eye_outlined, color: Color(0xFFD6B878)),
                    const SizedBox(width: 10),
                    Text(
                      'Viewed by ${viewers.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (viewers.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No one has viewed this story yet.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: viewers.length,
                      separatorBuilder: (_, __) => Divider(
                        color: Colors.white.withValues(alpha: 0.08),
                        height: 18,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> viewer = viewers[index];
                        final int viewerId =
                            int.tryParse('${viewer['viewer_user_id']}') ?? 0;
                        final String displayName =
                            (viewer['display_name'] ??
                                    viewer['users_name'] ??
                                    'User')
                                .toString();
                        final String username = (viewer['username'] ?? '').toString();
                        final List<String> imageUrls = AppImageUrls.profileAvatar(
                          avatarUrl: (viewer['avatar_url'] ?? '').toString(),
                          imagePath: (viewer['users_image'] ?? '').toString(),
                        );

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: viewerId > 0
                              ? () {
                                  Get.back();
                                  Get.to(() => ProfilePage(userId: viewerId));
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
                          subtitle: Text(
                            username.isNotEmpty
                                ? '@${username.replaceAll('@', '')}'
                                : _formatViewTimestamp(viewer['viewed_at']?.toString() ?? ''),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.66),
                            ),
                          ),
                          trailing: Text(
                            _formatViewTimestamp(viewer['viewed_at']?.toString() ?? ''),
                            style: const TextStyle(
                              color: Color(0xFFD6B878),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatViewTimestamp(String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      if (raw.length >= 16) {
        return raw.substring(0, 16).replaceFirst('T', ' ');
      }
      return raw.isEmpty ? 'Now' : raw;
    }

    final String hour = parsed.hour.toString().padLeft(2, '0');
    final String minute = parsed.minute.toString().padLeft(2, '0');
    final String day = parsed.day.toString().padLeft(2, '0');
    final String month = parsed.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  Future<void> _initVideoIfNeeded() async {
    final List<String> urls = AppImageUrls.item(_currentMediaPath);
    if (urls.isEmpty) {
      if (mounted) {
        setState(() => _videoError = true);
        _startProgress(const Duration(seconds: 5));
      }
      return;
    }

    for (final String url in urls) {
      try {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        await controller.setLooping(false);
        await controller.play();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        controller.addListener(_handleVideoTick);
        setState(() {
          _videoController = controller;
          _videoReady = true;
          _videoError = false;
        });
        _startProgress(controller.value.duration);
        return;
      } catch (_) {
        continue;
      }
    }

    if (mounted) {
      setState(() => _videoError = true);
      _startProgress(const Duration(seconds: 5));
    }
  }

  void _handleVideoTick() {
    final VideoPlayerController? controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (controller.value.duration > Duration.zero) {
      final double progress = controller.value.position.inMilliseconds /
          controller.value.duration.inMilliseconds;
      if (progress.isFinite) {
        _progressController.value = progress.clamp(0.0, 1.0);
      }
    }
    if (controller.value.position >= controller.value.duration &&
        !controller.value.isPlaying) {
      _goToNextStory();
    }
  }

  Future<void> _disposeVideoController() async {
    final VideoPlayerController? controller = _videoController;
    _videoController = null;
    if (controller != null) {
      controller.removeListener(_handleVideoTick);
      await controller.dispose();
    }
  }

  Future<void> _goToNextStory() async {
    if (!mounted) return;
    if (_currentIndex >= _stories.length - 1) {
      Get.back();
      return;
    }
    setState(() => _currentIndex += 1);
    await _loadCurrentStory();
  }

  Future<void> _goToPreviousStory() async {
    if (!mounted) return;
    if (_currentIndex <= 0) {
      _progressController.forward(from: 0);
      if (_videoController != null && _videoController!.value.isInitialized) {
        await _videoController!.seekTo(Duration.zero);
        await _videoController!.play();
      }
      return;
    }
    setState(() => _currentIndex -= 1);
    await _loadCurrentStory();
  }

  Future<void> _togglePlayPause() async {
    if (_isVideo && _videoController != null && _videoController!.value.isInitialized) {
      if (_videoController!.value.isPlaying) {
        await _videoController!.pause();
        _progressController.stop();
      } else {
        await _videoController!.play();
        _progressController.forward();
      }
    } else {
      if (_progressController.isAnimating) {
        _progressController.stop();
      } else {
        _progressController.forward();
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _progressController.dispose();
    _disposeVideoController();
    super.dispose();
  }

  Widget _buildStoryMedia() {
    if (_isVideo) {
      if (_videoReady && _videoController != null) {
        return GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: 0.12)),
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black.withValues(alpha: 0.42),
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: const Color(0xFF111111)),
          if (!_videoError)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD6B878),
              ),
            ),
          if (_videoError)
            const Center(
              child: Icon(
                Icons.videocam_off_rounded,
                color: Colors.white70,
                size: 42,
              ),
            ),
        ],
      );
    }

    return FallbackNetworkImage(
      imageUrls: AppImageUrls.item(_currentMediaPath),
      label: _currentUserName,
      fit: BoxFit.cover,
    );
  }

  Widget _buildProgressBars() {
    return Row(
      children: List<Widget>.generate(_stories.length, (int index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == _stories.length - 1 ? 0 : 4),
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(999),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) {
                  final double value = index < _currentIndex
                      ? 1
                      : index == _currentIndex
                          ? _progressController.value
                          : 0;
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value,
                      child: Container(color: const Color(0xFFD6B878)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _buildStoryMedia(),
            Positioned.fill(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToPreviousStory,
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _goToNextStory,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Column(
                children: <Widget>[
                  _buildProgressBars(),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD6B878),
                            width: 1.4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _currentUserName.isNotEmpty
                                ? _currentUserName.substring(0, 1).toUpperCase()
                                : 'P',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _currentUserName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _currentTimeLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.30),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (_isOwnStory) ...<Widget>[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _isLoadingViewers ? null : _showViewersSheet,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (_isLoadingViewers)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFD6B878),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Color(0xFFD6B878),
                                    size: 18,
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  '$_currentViewsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_currentStoryText.trim().isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _currentStoryText,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      _isOwnStory
                          ? 'Tap the eye icon to see who viewed your story'
                          : 'Reply to this story and your message will be sent to chat',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.74),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      if (!_isOwnStory)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: TextField(
                              controller: _commentController,
                              minLines: 1,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white),
                              textInputAction: TextInputAction.send,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Reply...',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.54),
                                ),
                              ),
                              onSubmitted: (_) => _sendStoryComment(),
                            ),
                          ),
                        ),
                      if (!_isOwnStory) const SizedBox(width: 8),
                      if (!_isOwnStory)
                        _StoryAction(
                          icon: _isSendingComment
                              ? Icons.hourglass_top_rounded
                              : Icons.send_rounded,
                          onTap: _sendStoryComment,
                        ),
                      if (!_isOwnStory) const SizedBox(width: 8),
                      if (!_isOwnStory)
                        _StoryAction(
                          icon: _reactionSent
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          onTap: _reactToStory,
                        ),
                      if (!_isOwnStory || _isVideo) ...<Widget>[
                        if (!_isOwnStory) const SizedBox(width: 8),
                        _StoryAction(
                          icon: _isVideo &&
                                  _videoController != null &&
                                  _videoController!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          onTap: _togglePlayPause,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryAction extends StatelessWidget {
  const _StoryAction({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFFD6B878),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF16120D)),
      ),
    );
  }
}
