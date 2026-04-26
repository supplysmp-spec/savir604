import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:tks/controler/video/comments_controller.dart';
import 'package:tks/controler/video/video_controller.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/video_model.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/data/datasource/remote/video/video_remote.dart';
import 'package:tks/view/screen/comment_page.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';
import 'package:tks/view/widget/video_item_widget.dart';

class FragranceCommunityScreen extends StatefulWidget {
  const FragranceCommunityScreen({
    super.key,
    this.initialTab = 0,
    this.targetPostId,
    this.openCommentsOnLoad = false,
  });

  final int initialTab;
  final int? targetPostId;
  final bool openCommentsOnLoad;

  @override
  State<FragranceCommunityScreen> createState() =>
      _FragranceCommunityScreenState();
}

class _FragranceCommunityScreenState extends State<FragranceCommunityScreen> {
  static const String _publicSiteUrl =
      'https://percious-fragance.savir-technology.com/';
  late final FragranceSocialData _socialData;
  late final VideoRemote _videoRemote;
  late final MyServices _myServices;
  late final int _currentUserId;
  final ImagePicker _picker = ImagePicker();

  int selectedTab = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> feedPosts = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> trendingPosts = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> communityMembers = <Map<String, dynamic>>[];
  List<VideoModel> reels = <VideoModel>[];
  bool _didHandleInitialPostTarget = false;

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _videoRemote = VideoRemote(Get.find<Crud>());
    _myServices = Get.find<MyServices>();
    _currentUserId = _myServices.sharedPreferences.getInt('id') ?? 0;
    selectedTab = widget.initialTab.clamp(0, 2);
    _loadInitialData();
  }

  Future<void> _openCreatePostSheet() async {
    final TextEditingController captionController = TextEditingController();
    final List<XFile> pickedMedia = <XFile>[];
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Create Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'myfont',
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: captionController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Share your fragrance thought...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.34)),
                      filled: true,
                      fillColor: const Color(0xFF1B1A17),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF3B3125)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF3B3125)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFD6B878)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _CreateMediaChip(
                        icon: Icons.image_outlined,
                        label: 'Photo',
                        onTap: () async {
                          final XFile? selected = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (selected != null) {
                            setModalState(() {
                              pickedMedia.clear();
                              pickedMedia.add(selected);
                            });
                          }
                        },
                      ),
                      _CreateMediaChip(
                        icon: Icons.collections_outlined,
                        label: 'Gallery',
                        onTap: () async {
                          final List<XFile> selected =
                              await _picker.pickMultiImage();
                          if (selected.isNotEmpty) {
                            setModalState(() {
                              pickedMedia
                                ..clear()
                                ..addAll(selected);
                            });
                          }
                        },
                      ),
                      _CreateMediaChip(
                        icon: Icons.videocam_outlined,
                        label: 'Video',
                        onTap: () async {
                          final XFile? selected = await _picker.pickVideo(
                              source: ImageSource.gallery);
                          if (selected != null) {
                            setModalState(() {
                              pickedMedia.clear();
                              pickedMedia.add(selected);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (pickedMedia.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pickedMedia
                          .map(
                            (XFile file) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1A17),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFF3B3125)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    _isVideoFile(file)
                                        ? Icons.videocam_outlined
                                        : Icons.image_outlined,
                                    color: const Color(0xFFD6B878),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 170),
                                    child: Text(
                                      file.name,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setModalState(() => isSubmitting = true);
                              final Map<String, dynamic> response =
                                  await _socialData.createCommunityPost(
                                userId: _currentUserId,
                                postText: captionController.text.trim(),
                                mediaFiles: pickedMedia,
                              );
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              await _loadInitialData();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    (response['status'] ?? '') == 'success'
                                        ? 'Post published successfully.'
                                        : (response['message'] ??
                                                'Unable to publish post')
                                            .toString(),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        foregroundColor: const Color(0xFF16120D),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Publish Post',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCreateReelSheet() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController captionController = TextEditingController();
    XFile? pickedVideo;
    String visibility = 'public';
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                18,
                18,
                18 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Create Reel',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _sheetInputDecoration('Reel title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: captionController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: _sheetInputDecoration(
                          'Tell people about this reel...'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _CreateMediaChip(
                          icon: Icons.video_library_outlined,
                          label: pickedVideo == null
                              ? 'Choose Video'
                              : 'Change Video',
                          onTap: () async {
                            final XFile? selected = await _picker.pickVideo(
                                source: ImageSource.gallery);
                            if (selected != null) {
                              setModalState(() => pickedVideo = selected);
                            }
                          },
                        ),
                        _CreateMediaChip(
                          icon: visibility == 'public'
                              ? Icons.public_rounded
                              : Icons.people_alt_outlined,
                          label:
                              visibility == 'public' ? 'Public' : 'Followers',
                          onTap: () {
                            setModalState(() {
                              visibility = visibility == 'public'
                                  ? 'followers'
                                  : 'public';
                            });
                          },
                        ),
                      ],
                    ),
                    if (pickedVideo != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1A17),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF3B3125)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.videocam_outlined,
                                color: Color(0xFFD6B878)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                pickedVideo!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting || pickedVideo == null
                            ? null
                            : () async {
                                setModalState(() => isSubmitting = true);
                                final Map<String, dynamic> response =
                                    await _socialData.createReel(
                                  userId: _currentUserId,
                                  videoFile: pickedVideo!,
                                  title: titleController.text.trim(),
                                  description: captionController.text.trim(),
                                  visibility: visibility,
                                );
                                if (!mounted) return;
                                Navigator.of(context).pop();
                                await _loadInitialData();
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      (response['status'] ?? '') == 'success'
                                          ? 'Reel published successfully.'
                                          : (response['message'] ??
                                                  'Unable to publish reel')
                                              .toString(),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B878),
                          foregroundColor: const Color(0xFF16120D),
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isSubmitting ? 'Publishing...' : 'Publish Reel',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openCommentsSheet(Map<String, dynamic> post) async {
    final int postId = int.tryParse('${post['post_id']}') ?? 0;
    if (postId <= 0) return;

    final TextEditingController commentController = TextEditingController();
    List<Map<String, dynamic>> comments =
        await _socialData.getPostComments(postId);
    bool isSending = false;
    final String postOwnerName = _displayName(post);

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setModalState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  18 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Comments',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'myfont',
                              fontSize: 26,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1A17),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFF3B3125)),
                          ),
                          child: Text(
                            '${comments.length}',
                            style: const TextStyle(
                              color: Color(0xFFD6B878),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Join the conversation on $postOwnerName\'s post.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 340,
                      child: comments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    color: Colors.white.withValues(alpha: 0.28),
                                    size: 34,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No comments yet',
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.82),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Be the first to share something thoughtful.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.52),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: comments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (BuildContext context, int index) {
                                final Map<String, dynamic> comment =
                                    comments[index];
                                final int commentUserId =
                                    int.tryParse('${comment['user_id'] ?? 0}') ??
                                        0;
                                final String name =
                                    _commentDisplayName(comment);
                                final String text =
                                    (comment['comment_text'] ?? '').toString();
                                final String time = _commentTimeLabel(comment);
                                final List<String> avatarUrls =
                                    _avatarUrls(comment);
                                return Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B1A17),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: const Color(0xFF3B3125)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      avatarUrls.isNotEmpty
                                          ? ClipOval(
                                              child: FallbackNetworkImage(
                                                imageUrls: avatarUrls,
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                label: name,
                                              ),
                                            )
                                          : Container(
                                              width: 40,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF2A2117),
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                _avatarInitial(name),
                                                style: const TextStyle(
                                                  color: Color(0xFFD6B878),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  time,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.48),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                if (commentUserId ==
                                                    _currentUserId)
                                                  IconButton(
                                                    onPressed: () async {
                                                      final int commentId =
                                                          int.tryParse(
                                                                '${comment['comment_id'] ?? 0}',
                                                              ) ??
                                                              0;
                                                      if (commentId <= 0) {
                                                        return;
                                                      }
                                                      final Map<String, dynamic>
                                                          response =
                                                          await _socialData
                                                              .deletePostComment(
                                                        commentId: commentId,
                                                        userId: _currentUserId,
                                                      );
                                                      if ((response['status'] ??
                                                              '') ==
                                                          'success') {
                                                        comments =
                                                            await _socialData
                                                                .getPostComments(
                                                          postId,
                                                        );
                                                        setModalState(() {});
                                                        if (mounted) {
                                                          setState(() {
                                                            _patchPostById(
                                                              postId,
                                                              (Map<String,
                                                                      dynamic>
                                                                  current) {
                                                                final int
                                                                    currentCount =
                                                                    int.tryParse(
                                                                          '${current['comments_count'] ?? 0}',
                                                                        ) ??
                                                                        0;
                                                                return <String,
                                                                    dynamic>{
                                                                  ...current,
                                                                  'comments_count':
                                                                      currentCount >
                                                                              0
                                                                          ? currentCount -
                                                                              1
                                                                          : 0,
                                                                };
                                                              },
                                                            );
                                                          });
                                                        }
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.delete_outline_rounded,
                                                      size: 18,
                                                      color: Color(0xFFB65B4F),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              text,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(alpha: 0.82),
                                                height: 1.45,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Write a comment...',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.34)),
                              filled: true,
                              fillColor: const Color(0xFF1B1A17),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Color(0xFF3B3125)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Color(0xFF3B3125)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD6B878)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: isSending
                              ? null
                              : () async {
                                  final String trimmedComment =
                                      commentController.text.trim();
                                  if (trimmedComment.isEmpty) return;
                                  setModalState(() => isSending = true);
                                  final Map<String, dynamic> response =
                                      await _socialData.addPostComment(
                                    postId: postId,
                                    userId: _currentUserId,
                                    commentText: trimmedComment,
                                  );
                                  if ((response['status'] ?? '') == 'success') {
                                    final Map<String, dynamic> createdComment =
                                        _buildCreatedCommentPayload(
                                      response: response,
                                      commentText: trimmedComment,
                                    );
                                    comments = <Map<String, dynamic>>[
                                      createdComment,
                                      ...comments,
                                    ];
                                    commentController.clear();
                                    setModalState(() {});
                                    if (mounted) {
                                      setState(() {
                                        _patchPostById(postId,
                                            (Map<String, dynamic> current) {
                                          final int currentCount =
                                              int.tryParse(
                                                    '${current['comments_count'] ?? 0}',
                                                  ) ??
                                                  0;
                                          return <String, dynamic>{
                                            ...current,
                                            'comments_count': currentCount + 1,
                                          };
                                        });
                                      });
                                    }
                                  }
                                  setModalState(() => isSending = false);
                                },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD6B878),
                              shape: BoxShape.circle,
                            ),
                            child: isSending
                                ? const Padding(
                                    padding: EdgeInsets.all(13),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF16120D),
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Color(0xFF16120D),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openReactionSheet(Map<String, dynamic> post) async {
    final List<_ReactionOption> reactions = <_ReactionOption>[
      const _ReactionOption(type: 'like', label: 'Like', emoji: '👍'),
      const _ReactionOption(type: 'love', label: 'Love', emoji: '❤️'),
      const _ReactionOption(type: 'laugh', label: 'Laugh', emoji: '😂'),
      const _ReactionOption(type: 'support', label: 'Support', emoji: '👏'),
      const _ReactionOption(type: 'angry', label: 'Angry', emoji: '😠'),
    ];
    final String currentReaction =
        (post['viewer_reaction_type'] ?? '').toString();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF11100E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'React to Post',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'myfont',
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose how you want to respond to this post.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: reactions
                    .map(
                      (_ReactionOption reaction) => InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _toggleLike(post, reactionType: reaction.type);
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 104,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: currentReaction == reaction.type
                                ? const Color(0xFF2A2117)
                                : const Color(0xFF1B1A17),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: currentReaction == reaction.type
                                  ? const Color(0xFFD6B878)
                                  : const Color(0xFF3B3125),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(_reactionEmojiForType(reaction.type),
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 8),
                              Text(
                                reaction.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_reactionCount(post, reaction.type)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.58),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openProfile(int userId) {
    if (userId <= 0) {
      return;
    }
    Get.to(() => ProfilePage(userId: userId));
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> loadedFeed = await _socialData.getCommunityPosts(
      viewerId: _currentUserId,
      mode: 'feed',
    );
    List<Map<String, dynamic>> loadedTrending =
        await _socialData.getCommunityPosts(
      viewerId: _currentUserId,
      mode: 'trending',
    );
    final List<Map<String, dynamic>> loadedMembers =
        await _socialData.discoverProfiles(
      viewerId: _currentUserId,
      limit: 150,
    );
    final List<VideoModel> loadedReels =
        await _videoRemote.fetchVideos(viewerId: _currentUserId);

    if (widget.targetPostId != null && widget.targetPostId! > 0) {
      loadedFeed = _prioritizePost(loadedFeed, widget.targetPostId!);
      loadedTrending = _prioritizePost(loadedTrending, widget.targetPostId!);
    }

    if (!mounted) return;
    setState(() {
      feedPosts = loadedFeed;
      trendingPosts = loadedTrending;
      communityMembers = loadedMembers;
      reels = loadedReels;
      isLoading = false;
    });
    _maybeOpenInitialPostTarget();
  }

  List<Map<String, dynamic>> _prioritizePost(
    List<Map<String, dynamic>> posts,
    int targetPostId,
  ) {
    final int index = posts.indexWhere(
        (Map<String, dynamic> post) => '${post['post_id']}' == '$targetPostId');
    if (index <= 0) {
      return posts;
    }

    final List<Map<String, dynamic>> reordered =
        List<Map<String, dynamic>>.from(posts);
    final Map<String, dynamic> target = reordered.removeAt(index);
    reordered.insert(0, target);
    return reordered;
  }

  Future<void> _maybeOpenInitialPostTarget() async {
    if (_didHandleInitialPostTarget || isLoading || !mounted) {
      return;
    }

    final int targetPostId = widget.targetPostId ?? 0;
    if (targetPostId <= 0) {
      return;
    }

    Map<String, dynamic>? targetPost;
    int? targetTab;

    final int feedIndex = feedPosts.indexWhere(
        (Map<String, dynamic> post) => '${post['post_id']}' == '$targetPostId');
    if (feedIndex >= 0) {
      targetPost = feedPosts[feedIndex];
      targetTab = 0;
    } else {
      final int trendingIndex = trendingPosts.indexWhere(
          (Map<String, dynamic> post) =>
              '${post['post_id']}' == '$targetPostId');
      if (trendingIndex >= 0) {
        targetPost = trendingPosts[trendingIndex];
        targetTab = 1;
      }
    }

    if (targetPost == null) {
      return;
    }

    _didHandleInitialPostTarget = true;

    if (selectedTab != targetTab) {
      setState(() => selectedTab = targetTab!);
    }

    if (!widget.openCommentsOnLoad) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _openCommentsSheet(targetPost!);
    });
  }

  Future<void> _toggleLike(Map<String, dynamic> post,
      {String reactionType = 'like'}) async {
    final int postId = int.tryParse('${post['post_id']}') ?? 0;
    if (postId <= 0 || _currentUserId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.togglePostLike(
      postId: postId,
      userId: _currentUserId,
      reactionType: reactionType,
    );

    if ((response['status'] ?? '') != 'success') {
      return;
    }

    final int likesCount = int.tryParse('${response['likes_count']}') ?? 0;
    final String currentReaction =
        (response['current_reaction_type'] ?? '').toString();
    final Map<String, dynamic> reactionCounts =
        (response['reaction_counts'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

    if (!mounted) return;
    setState(() {
      _patchPostById(postId, (Map<String, dynamic> current) {
        return <String, dynamic>{
          ...current,
          'is_liked': currentReaction.isNotEmpty ? 1 : 0,
          'likes_count': likesCount,
          'viewer_reaction_type': currentReaction,
          'like_count': reactionCounts['like'] ?? current['like_count'] ?? 0,
          'love_count': reactionCounts['love'] ?? current['love_count'] ?? 0,
          'laugh_count': reactionCounts['laugh'] ?? current['laugh_count'] ?? 0,
          'support_count':
              reactionCounts['support'] ?? current['support_count'] ?? 0,
          'angry_count': reactionCounts['angry'] ?? current['angry_count'] ?? 0,
        };
      });
    });
  }

  void _patchPostById(
    int postId,
    Map<String, dynamic> Function(Map<String, dynamic> current) patch,
  ) {
    void patchList(List<Map<String, dynamic>> list) {
      for (int i = 0; i < list.length; i++) {
        if ('${list[i]['post_id']}' == '$postId') {
          list[i] = patch(Map<String, dynamic>.from(list[i]));
        }
      }
    }

    patchList(feedPosts);
    patchList(trendingPosts);
  }

  void _removePostById(int postId) {
    feedPosts.removeWhere(
      (Map<String, dynamic> post) => '${post['post_id']}' == '$postId',
    );
    trendingPosts.removeWhere(
      (Map<String, dynamic> post) => '${post['post_id']}' == '$postId',
    );
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    final int postId = int.tryParse('${post['post_id']}') ?? 0;
    if (postId <= 0 || _currentUserId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.deletePost(
      postId: postId,
      userId: _currentUserId,
    );

    if (!mounted) return;
    if ((response['status'] ?? '') == 'success') {
      setState(() => _removePostById(postId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (response['message'] ?? 'Unable to delete this post.').toString(),
        ),
      ),
    );
  }

  Future<void> _deleteReel(VideoModel video) async {
    final int videoId = video.videoId;
    if (videoId <= 0 || _currentUserId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.deleteReel(
      videoId: videoId,
      userId: _currentUserId,
    );

    if (!mounted) return;
    if ((response['status'] ?? '') == 'success') {
      setState(() {
        reels.removeWhere((VideoModel item) => item.videoId == videoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reel deleted successfully.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (response['message'] ?? 'Unable to delete this reel.').toString(),
        ),
      ),
    );
  }

  Future<void> _openPostInteractionsSheet(Map<String, dynamic> post) async {
    final int postId = int.tryParse('${post['post_id']}') ?? 0;
    if (postId <= 0 || _currentUserId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.getPostInteractions(
      postId: postId,
      userId: _currentUserId,
    );
    if (!mounted) return;

    if ((response['status'] ?? '') != 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (response['message'] ?? 'Unable to load post activity.').toString(),
          ),
        ),
      );
      return;
    }

    await _showActivitySheet(
      title: 'Post Activity',
      summary: Map<String, dynamic>.from(
        (response['summary'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      sections: <_ActivitySection>[
        _ActivitySection(
          title: 'Reactions',
          items: ((response['reactions'] as List?) ?? <dynamic>[])
              .map((dynamic item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          subtitleBuilder: (Map<String, dynamic> item) =>
              'Reaction: ${(item['reaction_type'] ?? 'like').toString()}',
          timeKey: 'created_at',
        ),
        _ActivitySection(
          title: 'Comments',
          items: ((response['comments'] as List?) ?? <dynamic>[])
              .map((dynamic item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          subtitleBuilder: (Map<String, dynamic> item) =>
              (item['comment_text'] ?? '').toString(),
          timeKey: 'created_at',
        ),
      ],
    );
  }

  Future<void> _openVideoInteractionsSheet(VideoModel video) async {
    if (video.videoId <= 0 || _currentUserId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.getVideoInteractions(
      videoId: video.videoId,
      userId: _currentUserId,
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

    await _showActivitySheet(
      title: 'Reel Activity',
      summary: Map<String, dynamic>.from(
        (response['summary'] as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{},
      ),
      sections: <_ActivitySection>[
        _ActivitySection(
          title: 'Viewers',
          items: ((response['viewers'] as List?) ?? <dynamic>[])
              .map((dynamic item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          subtitleBuilder: (_) => 'Viewed your reel',
          timeKey: 'viewed_at',
        ),
        _ActivitySection(
          title: 'Likes',
          items: ((response['likes'] as List?) ?? <dynamic>[])
              .map((dynamic item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          subtitleBuilder: (_) => 'Liked your reel',
          timeKey: 'like_date',
        ),
        _ActivitySection(
          title: 'Comments',
          items: ((response['comments'] as List?) ?? <dynamic>[])
              .map((dynamic item) => Map<String, dynamic>.from(item as Map))
              .toList(),
          subtitleBuilder: (Map<String, dynamic> item) =>
              (item['comment_text'] ?? '').toString(),
          timeKey: 'comment_date',
        ),
      ],
    );
  }

  Future<void> _showActivitySheet({
    required String title,
    required Map<String, dynamic> summary,
    required List<_ActivitySection> sections,
  }) async {
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
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'myfont',
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: summary.entries
                        .map(
                          (MapEntry<String, dynamic> entry) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1A17),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF3B3125)),
                            ),
                            child: Text(
                              '${entry.key.replaceAll('_', ' ')}: ${entry.value}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  ...sections.map(
                    (_ActivitySection section) => _ActivitySectionWidget(
                      section: section,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _buildCreatedCommentPayload({
    required Map<String, dynamic> response,
    required String commentText,
  }) {
    final dynamic data = response['data'] ?? response['comment'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    final String displayName =
        (_myServices.sharedPreferences.getString('display_name') ?? '')
            .trim();
    final String userName =
        (_myServices.sharedPreferences.getString('users_name') ??
                _myServices.sharedPreferences.getString('username') ??
                '')
            .trim();

    return <String, dynamic>{
      'comment_id': DateTime.now().microsecondsSinceEpoch,
      'post_id': response['post_id'] ?? '',
      'user_id': _currentUserId,
      'comment_text': commentText,
      'display_name': displayName,
      'users_name': userName,
      'created_at': DateTime.now().toIso8601String(),
      'avatar_url': _myServices.sharedPreferences.getString('avatar_url') ?? '',
      'profile_image_url':
          _myServices.sharedPreferences.getString('avatar_url') ?? '',
      'users_image': _myServices.sharedPreferences.getString('users_image') ?? '',
    };
  }

  Future<void> _openReactionPicker(Map<String, dynamic> post) async {
    final _ReactionOption? selected = await showModalBottomSheet<_ReactionOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ReactionPickerSheet(
          post: post,
          onSelected: (_ReactionOption option) {
            Navigator.of(context).pop(option);
          },
        );
      },
    );

    if (selected == null) return;
    await _toggleLike(post, reactionType: selected.type);
  }

  Future<void> _toggleFollow(int followedUserId) async {
    if (_currentUserId <= 0 ||
        followedUserId <= 0 ||
        followedUserId == _currentUserId) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.toggleFollow(
      followerUserId: _currentUserId,
      followedUserId: followedUserId,
    );
    final bool nowFollowing = (response['action'] ?? '') == 'followed';

    void patchPosts(List<Map<String, dynamic>> list) {
      for (int i = 0; i < list.length; i++) {
        if ('${list[i]['user_id']}' == '$followedUserId') {
          list[i] = <String, dynamic>{
            ...list[i],
            'is_following': nowFollowing ? 1 : 0,
          };
        }
      }
    }

    void patchMembers(List<Map<String, dynamic>> list) {
      for (int i = 0; i < list.length; i++) {
        if ('${list[i]['users_id']}' == '$followedUserId') {
          list[i] = <String, dynamic>{
            ...list[i],
            'is_following': nowFollowing ? 1 : 0,
          };
        }
      }
    }

    if (!mounted) return;
    setState(() {
      patchPosts(feedPosts);
      patchPosts(trendingPosts);
      patchMembers(communityMembers);
    });
  }

  String _displayName(Map<String, dynamic> data) {
    final String displayName = (data['display_name'] ?? '').toString().trim();
    final String name = (data['users_name'] ?? '').toString().trim();
    return displayName.isNotEmpty
        ? displayName
        : (name.isNotEmpty ? name : 'Creator');
  }

  String _timeLabel(Map<String, dynamic> data) {
    final String createdAt = (data['created_at'] ?? '').toString().trim();
    if (createdAt.isEmpty || createdAt.length < 16) {
      return 'Now';
    }
    return createdAt.substring(0, 16).replaceFirst('T', ' ');
  }

  String _commentDisplayName(Map<String, dynamic> comment) {
    final String displayName =
        (comment['display_name'] ?? '').toString().trim();
    final String userName = (comment['users_name'] ?? '').toString().trim();
    if (displayName.isNotEmpty) return displayName;
    if (userName.isNotEmpty) return userName;
    return 'Member';
  }

  String _commentTimeLabel(Map<String, dynamic> comment) {
    final String createdAt = (comment['created_at'] ?? '').toString().trim();
    if (createdAt.isEmpty) {
      return 'Now';
    }
    if (createdAt.length >= 16) {
      return createdAt.substring(0, 16).replaceFirst('T', ' ');
    }
    return createdAt;
  }

  String _avatarInitial(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'M';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  List<String> _avatarUrls(Map<String, dynamic> data) {
    return AppImageUrls.profileAvatar(
      avatarUrl: (data['profile_image_url'] ?? data['avatar_url']).toString(),
      imagePath: (data['peer_image'] ?? data['users_image']).toString(),
    );
  }

  int _reactionCount(Map<String, dynamic> post, String reactionType) {
    return int.tryParse('${post['${reactionType}_count'] ?? 0}') ?? 0;
  }

  Future<void> _sharePost(Map<String, dynamic> post) async {
    final String author = _displayName(post);
    final String body = _postBody(post).trim();
    final String postType =
        (post['post_type'] ?? 'community').toString().replaceAll('_', ' ');

    final List<String> parts = <String>[
      '$author shared a $postType post on Savir.',
      if (body.isNotEmpty) body,
      _publicSiteUrl,
    ];

    await Share.share(
      parts.join('\n\n'),
      subject: '$author on Savir Community',
    );
  }

  List<Map<String, String>> _mediaItems(Map<String, dynamic> post) {
    final String bundle = (post['media_bundle'] ?? '').toString();
    if (bundle.trim().isEmpty) {
      final String bottleImage =
          (post['custom_perfume_bottle_image'] ?? '').toString().trim();
      if (bottleImage.isNotEmpty) {
        return AppImageUrls.item(bottleImage)
            .map((String url) => <String, String>{'type': 'image', 'url': url})
            .toList();
      }
      return const <Map<String, String>>[];
    }

    final List<Map<String, String>> items = bundle
        .split('###')
        .map((String entry) => entry.split('||'))
        .where((List<String> parts) => parts.length >= 2)
        .expand((List<String> parts) {
      final String type = parts[0].trim().toLowerCase();
      final String url = parts[1].trim();
      if (url.isEmpty) {
        return const <Map<String, String>>[];
      }
      return AppImageUrls.item(url)
          .map((String normalized) => <String, String>{
                'type': type == 'video' ? 'video' : 'image',
                'url': normalized,
              })
          .toList();
    }).toList();
    return items;
  }

  String _postBody(Map<String, dynamic> post) {
    final String postText = (post['post_text'] ?? '').toString().trim();
    if (postText.isNotEmpty) {
      return postText;
    }

    final String customName =
        (post['custom_perfume_name'] ?? '').toString().trim();
    if (customName.isNotEmpty) {
      return '$customName is now live in the community.';
    }

    return 'A new fragrance moment has been shared with the community.';
  }

  List<Map<String, dynamic>> get _communityCreators => communityMembers;

  bool _isVideoFile(XFile file) {
    final String lower = file.name.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm');
  }

  void _changeTab(int index) {
    if (selectedTab == index) return;
    if (index != 2 && Get.isRegistered<VideoController>()) {
      Get.find<VideoController>().pauseAll();
    }
    setState(() => selectedTab = index);
  }

  Widget _buildCommunityHeader({
    bool compact = false,
    bool showTitle = true,
  }) {
    final double titleSize = compact ? 22 : 28;
    final double spacing = compact ? 14 : 18;

    return Column(
      children: <Widget>[
        if (showTitle)
          Center(
            child: Text(
              'Community',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'myfont',
                fontSize: titleSize,
              ),
            ),
          ),
        if (showTitle) SizedBox(height: spacing),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            SizedBox(
              width: compact ? 112 : 104,
              child: _CommunityTab(
                title: 'Feed',
                selected: selectedTab == 0,
                onTap: () => _changeTab(0),
              ),
            ),
            SizedBox(
              width: compact ? 112 : 104,
              child: _CommunityTab(
                title: 'Trending',
                selected: selectedTab == 1,
                onTap: () => _changeTab(1),
              ),
            ),
            SizedBox(
              width: compact ? 148 : 128,
              child: _CommunityTab(
                title: 'Video Reels',
                selected: selectedTab == 2,
                onTap: () => _changeTab(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardBody() {
    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFFD6B878),
        backgroundColor: const Color(0xFF181715),
        onRefresh: _loadInitialData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
          children: <Widget>[
            _buildCommunityHeader(),
            const SizedBox(height: 18),
            if (selectedTab != 2) ...<Widget>[
              _WhatsNewComposer(
                onTap: _openCreatePostSheet,
              ),
              const SizedBox(height: 18),
            ],
            if (selectedTab == 0)
              _PostsColumn(
                posts: feedPosts,
                displayName: _displayName,
                timeLabel: _timeLabel,
                mediaItems: _mediaItems,
                postBody: _postBody,
                onLike: _toggleLike,
                onReact: _openReactionPicker,
                onShare: _sharePost,
                onFollow: _toggleFollow,
                onOpenProfile: _openProfile,
                onComment: _openCommentsSheet,
                onDelete: _deletePost,
                onInsights: _openPostInteractionsSheet,
                currentUserId: _currentUserId,
              ),
            if (selectedTab == 1)
              _TrendingTab(
                posts: trendingPosts,
                creators: _communityCreators,
                displayName: _displayName,
                timeLabel: _timeLabel,
                mediaItems: _mediaItems,
                postBody: _postBody,
                onLike: _toggleLike,
                onReact: _openReactionPicker,
                onShare: _sharePost,
                onFollow: _toggleFollow,
                onOpenProfile: _openProfile,
                onComment: _openCommentsSheet,
                onDelete: _deletePost,
                onInsights: _openPostInteractionsSheet,
                currentUserId: _currentUserId,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelsBody() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: _ReelsTab(
            reels: reels,
            onCreateReel: _openCreateReelSheet,
            onOpenComments: _openVideoComments,
            onDeleteReel: _deleteReel,
            onOpenInsights: _openVideoInteractionsSheet,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF090909),
                  Color(0xF2090909),
                  Color(0x00090909),
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Video Reels',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'myfont',
                              fontSize: 26,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                        _CreateReelTopButton(onTap: _openCreateReelSheet),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _CommunityTab(
                            title: 'Feed',
                            selected: selectedTab == 0,
                            onTap: () => _changeTab(0),
                          ),
                          const SizedBox(width: 10),
                          _CommunityTab(
                            title: 'Trending',
                            selected: selectedTab == 1,
                            onTap: () => _changeTab(1),
                          ),
                          const SizedBox(width: 10),
                          _CommunityTab(
                            title: 'Video Reels',
                            selected: selectedTab == 2,
                            onTap: () => _changeTab(2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openVideoComments(VideoModel video) {
    Get.bottomSheet(
      CommentsPage(videoId: video.videoId, userId: _currentUserId),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).whenComplete(() {
      try {
        Get.delete<CommentsController>(tag: 'comments_${video.videoId}');
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD6B878)),
            )
          : selectedTab == 2
              ? _buildReelsBody()
              : _buildStandardBody(),
    );
  }
}

InputDecoration _sheetInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.34)),
    filled: true,
    fillColor: const Color(0xFF1B1A17),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFF3B3125)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFF3B3125)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD6B878)),
    ),
  );
}

class _CommunityTab extends StatelessWidget {
  const _CommunityTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.20)
              : Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.white70 : Colors.white24,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PostsColumn extends StatelessWidget {
  const _PostsColumn({
    required this.posts,
    required this.displayName,
    required this.timeLabel,
    required this.mediaItems,
    required this.postBody,
    required this.onLike,
    required this.onReact,
    required this.onShare,
    required this.onFollow,
    required this.onOpenProfile,
    required this.onComment,
    required this.onDelete,
    required this.onInsights,
    required this.currentUserId,
  });

  final List<Map<String, dynamic>> posts;
  final String Function(Map<String, dynamic>) displayName;
  final String Function(Map<String, dynamic>) timeLabel;
  final List<Map<String, String>> Function(Map<String, dynamic>) mediaItems;
  final String Function(Map<String, dynamic>) postBody;
  final Future<void> Function(Map<String, dynamic>) onLike;
  final Future<void> Function(Map<String, dynamic>) onReact;
  final Future<void> Function(Map<String, dynamic>) onShare;
  final Future<void> Function(int) onFollow;
  final void Function(int) onOpenProfile;
  final Future<void> Function(Map<String, dynamic>) onComment;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Future<void> Function(Map<String, dynamic>) onInsights;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _EmptyState(message: 'No community posts yet.');
    }

    return Column(
      children: posts
          .map(
            (Map<String, dynamic> post) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _CommunityPostCard(
                post: post,
                displayName: displayName(post),
                timeLabel: timeLabel(post),
                mediaItems: mediaItems(post),
                bodyText: postBody(post),
                onLike: () => onLike(post),
                onReact: () => onReact(post),
                onShare: () => onShare(post),
                onFollow: () =>
                    onFollow(int.tryParse('${post['user_id']}') ?? 0),
                onOpenProfile: () =>
                    onOpenProfile(int.tryParse('${post['user_id']}') ?? 0),
                onComment: () => onComment(post),
                onDelete: () => onDelete(post),
                onInsights: () => onInsights(post),
                canFollow: currentUserId > 0 &&
                    '${post['user_id']}' != '$currentUserId',
              ),
            ),
          )
          .toList(),
    );
  }
}

class _TrendingTab extends StatelessWidget {
  const _TrendingTab({
    required this.posts,
    required this.creators,
    required this.displayName,
    required this.timeLabel,
    required this.mediaItems,
    required this.postBody,
    required this.onLike,
    required this.onReact,
    required this.onShare,
    required this.onFollow,
    required this.onOpenProfile,
    required this.onComment,
    required this.onDelete,
    required this.onInsights,
    required this.currentUserId,
  });

  final List<Map<String, dynamic>> posts;
  final List<Map<String, dynamic>> creators;
  final String Function(Map<String, dynamic>) displayName;
  final String Function(Map<String, dynamic>) timeLabel;
  final List<Map<String, String>> Function(Map<String, dynamic>) mediaItems;
  final String Function(Map<String, dynamic>) postBody;
  final Future<void> Function(Map<String, dynamic>) onLike;
  final Future<void> Function(Map<String, dynamic>) onReact;
  final Future<void> Function(Map<String, dynamic>) onShare;
  final Future<void> Function(int) onFollow;
  final void Function(int) onOpenProfile;
  final Future<void> Function(Map<String, dynamic>) onComment;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Future<void> Function(Map<String, dynamic>) onInsights;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Community Members',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'myfont',
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 14),
        if (creators.isEmpty)
          const _EmptyState(message: 'No members available yet.')
        else
          ...creators.asMap().entries.map(
                (MapEntry<int, Map<String, dynamic>> entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CreatorCard(
                    rank: entry.key + 1,
                    creator: entry.value,
                    displayName: displayName(entry.value),
                    onFollow: () => onFollow(
                      int.tryParse(
                              '${entry.value['user_id'] ?? entry.value['users_id']}') ??
                          0,
                    ),
                    onOpenProfile: () => onOpenProfile(
                      int.tryParse(
                              '${entry.value['user_id'] ?? entry.value['users_id']}') ??
                          0,
                    ),
                    canFollow: currentUserId > 0 &&
                        '${entry.value['user_id'] ?? entry.value['users_id']}' !=
                            '$currentUserId',
                  ),
                ),
              ),
        const SizedBox(height: 18),
        const Text(
          'Trending Posts',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'myfont',
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 14),
        if (posts.isEmpty)
          const _EmptyState(message: 'No trending posts yet.')
        else
          _CommunityPostCard(
            post: posts.first,
            displayName: displayName(posts.first),
            timeLabel: timeLabel(posts.first),
            mediaItems: mediaItems(posts.first),
            bodyText: postBody(posts.first),
            onLike: () => onLike(posts.first),
            onReact: () => onReact(posts.first),
            onShare: () => onShare(posts.first),
            onFollow: () =>
                onFollow(int.tryParse('${posts.first['user_id']}') ?? 0),
            onOpenProfile: () =>
                onOpenProfile(int.tryParse('${posts.first['user_id']}') ?? 0),
            onComment: () => onComment(posts.first),
            onDelete: () => onDelete(posts.first),
            onInsights: () => onInsights(posts.first),
            canFollow: currentUserId > 0 &&
                '${posts.first['user_id']}' != '$currentUserId',
          ),
      ],
    );
  }
}

class _ReelsTab extends StatefulWidget {
  const _ReelsTab({
    required this.reels,
    required this.onCreateReel,
    required this.onOpenComments,
    required this.onDeleteReel,
    required this.onOpenInsights,
  });

  final List<VideoModel> reels;
  final VoidCallback onCreateReel;
  final ValueChanged<VideoModel> onOpenComments;
  final ValueChanged<VideoModel> onDeleteReel;
  final ValueChanged<VideoModel> onOpenInsights;

  @override
  State<_ReelsTab> createState() => _ReelsTabState();
}

class _ReelsTabState extends State<_ReelsTab> {
  late final PageController _pageController;
  late final VideoController _videoController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _videoController = Get.isRegistered<VideoController>()
        ? Get.find<VideoController>()
        : Get.put(VideoController(Get.find<Crud>()));
    _syncVideos();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.reels.isEmpty) return;
      _videoController.setCurrentIndex(0);
    });
  }

  @override
  void didUpdateWidget(covariant _ReelsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncVideos();
    if (widget.reels.isEmpty) {
      _currentIndex = 0;
      return;
    }

    if (_currentIndex >= widget.reels.length) {
      _currentIndex = widget.reels.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
      _videoController.setCurrentIndex(_currentIndex);
    }
  }

  void _syncVideos() {
    _videoController.videos.assignAll(widget.reels);
  }

  @override
  void dispose() {
    if (Get.isRegistered<VideoController>()) {
      Get.find<VideoController>().pauseAll();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reels.isEmpty) {
      return Stack(
        children: <Widget>[
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFF090909),
                    Color(0xFF111111),
                    Color(0xFF090909),
                  ],
                ),
              ),
            ),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _EmptyState(
                message:
                    'No reels yet.\nPublish the first fragrance reel and start the scroll.',
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.reels.length,
            onPageChanged: (int index) {
              setState(() => _currentIndex = index);
              _videoController.setCurrentIndex(index);
            },
            itemBuilder: (BuildContext context, int index) {
              final VideoModel reel = widget.reels[index];
              return VideoItemWidget(
                video: reel,
                controller: _videoController,
                isActive: _currentIndex == index,
                onOpenComments: () => widget.onOpenComments(reel),
                onDelete: () => widget.onDeleteReel(reel),
                onOpenInsights: () => widget.onOpenInsights(reel),
                topInset: 150,
                bottomInset: 92,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CreateReelTopButton extends StatelessWidget {
  const _CreateReelTopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF181512),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD6B878)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFD6B878),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Color(0xFF16120D),
                  ),
                ),
              ),
              SizedBox(width: 7),
              Text(
                'Create Reel',
                style: TextStyle(
                  color: Color(0xFFE9DAB0),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityPostCard extends StatelessWidget {
  const _CommunityPostCard({
    required this.post,
    required this.displayName,
    required this.timeLabel,
    required this.mediaItems,
    required this.bodyText,
    required this.onLike,
    required this.onReact,
    required this.onShare,
    required this.onFollow,
    required this.onOpenProfile,
    required this.onComment,
    required this.onDelete,
    required this.onInsights,
    required this.canFollow,
  });

  final Map<String, dynamic> post;
  final String displayName;
  final String timeLabel;
  final List<Map<String, String>> mediaItems;
  final String bodyText;
  final VoidCallback onLike;
  final VoidCallback onReact;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpenProfile;
  final VoidCallback onComment;
  final VoidCallback onDelete;
  final VoidCallback onInsights;
  final bool canFollow;

  @override
  Widget build(BuildContext context) {
    final bool isLiked = '${post['is_liked']}' == '1';
    final bool isFollowing = '${post['is_following']}' == '1';
    final bool isOwnPost =
        '${post['user_id'] ?? 0}' == '${Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0}';
    final String tag = (post['post_type'] ?? 'Community').toString();
    final List<String> avatarUrls = AppImageUrls.profileAvatar(
      avatarUrl: (post['profile_image_url'] ?? post['avatar_url']).toString(),
      imagePath: (post['users_image'] ?? '').toString(),
    );
    final String currentReaction =
        (post['viewer_reaction_type'] ?? '').toString();
    final List<String> videoUrls = mediaItems
        .where((Map<String, String> item) => item['type'] == 'video')
        .map((Map<String, String> item) => item['url'] ?? '')
        .where((String url) => url.isNotEmpty)
        .toList();
    final bool hasVideo = videoUrls.isNotEmpty;
    final List<String> imageUrls = mediaItems
        .where((Map<String, String> item) => item['type'] == 'image')
        .map((Map<String, String> item) => item['url'] ?? '')
        .where((String url) => url.isNotEmpty)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: InkWell(
              onTap: onOpenProfile,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: <Widget>[
                  avatarUrls.isNotEmpty
                      ? ClipOval(
                          child: FallbackNetworkImage(
                            imageUrls: avatarUrls,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            label: displayName,
                          ),
                        )
                      : Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3A2C1B),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            displayName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFD6B878),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.58)),
                        ),
                      ],
                    ),
                  ),
                  if (canFollow)
                    TextButton(
                      onPressed: onFollow,
                      child: Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(
                          color: Color(0xFFD6B878),
                          fontWeight: FontWeight.w700,
                        ),
                        ),
                      ),
                  if (isOwnPost)
                    IconButton(
                      onPressed: onInsights,
                      icon: const Icon(
                        Icons.insights_outlined,
                        color: Color(0xFFD6B878),
                      ),
                    ),
                  if (isOwnPost)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFD6B878),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 340,
            width: double.infinity,
            child: mediaItems.isEmpty
                ? Container(
                    color: const Color(0xFF171614),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xFFD6B878),
                      size: 54,
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      hasVideo
                          ? _CommunityVideoPlayer(
                              videoUrl: videoUrls.first,
                              previewUrls: imageUrls,
                              label: displayName,
                            )
                          : FallbackNetworkImage(
                              imageUrls: imageUrls,
                              label: displayName,
                              fit: BoxFit.cover,
                            ),
                      if (!hasVideo && imageUrls.length > 1)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.46),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${imageUrls.length} photos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ReactionSummaryRow(post: post),
                const SizedBox(height: 12),
                _PostActionBar(
                  post: post,
                  currentReaction: currentReaction,
                  isLiked: isLiked,
                  onLike: onLike,
                  onReact: onReact,
                  onComment: onComment,
                  onShare: onShare,
                ),
                const SizedBox(height: 12),
                Text(
                  bodyText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                if ((post['custom_perfume_name'] ?? '')
                    .toString()
                    .trim()
                    .isNotEmpty) ...<Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1814),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF4E3E28)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (post['custom_perfume_name'] ?? '').toString(),
                          style: const TextStyle(
                            color: Color(0xFFD6B878),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Size: ${(post['custom_perfume_size_label'] ?? post['custom_perfume_volume_ml'] ?? '--').toString()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFF2F291E),
                    border: Border.all(color: const Color(0xFF5B482B)),
                  ),
                  child: Text(
                    tag.replaceAll('_', ' '),
                    style: const TextStyle(
                      color: Color(0xFFD6B878),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _reactionBreakdown(Map<String, dynamic> post) {
    final Map<String, String> reactionEmoji = <String, String>{
      'like': '👍',
      'love': '❤️',
      'laugh': '😂',
      'support': '👏',
      'angry': '😠',
    };
    final List<Widget> chips = <Widget>[];
    for (final MapEntry<String, String> entry in reactionEmoji.entries) {
      final int count = int.tryParse('${post['${entry.key}_count'] ?? 0}') ?? 0;
      if (count <= 0) continue;
      chips.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1814),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF4E3E28)),
          ),
          child: Text(
            '${entry.value} $count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return chips;
  }

  String _reactionEmoji(String reactionType, bool isLiked) {
    switch (reactionType) {
      case 'love':
        return '❤️';
      case 'laugh':
        return '😂';
      case 'support':
        return '👏';
      case 'angry':
        return '😠';
      case 'like':
        return '👍';
      default:
        return isLiked ? '👍' : '🙂';
    }
  }

  String _reactionLabel(String reactionType, bool isLiked) {
    switch (reactionType) {
      case 'love':
        return 'Love';
      case 'laugh':
        return 'Laugh';
      case 'support':
        return 'Support';
      case 'angry':
        return 'Angry';
      case 'like':
        return 'Like';
      default:
        return isLiked ? 'Like' : 'React';
    }
  }
}

class _ActivitySection {
  const _ActivitySection({
    required this.title,
    required this.items,
    required this.subtitleBuilder,
    required this.timeKey,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final String Function(Map<String, dynamic>) subtitleBuilder;
  final String timeKey;
}

class _ActivitySectionWidget extends StatelessWidget {
  const _ActivitySectionWidget({required this.section});

  final _ActivitySection section;

  String _displayName(Map<String, dynamic> item) {
    final String displayName = (item['display_name'] ?? '').toString().trim();
    final String userName = (item['users_name'] ?? '').toString().trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }
    if (userName.isNotEmpty) {
      return userName;
    }
    return 'Member';
  }

  String _timeLabel(Map<String, dynamic> item) {
    final String raw = (item[section.timeKey] ?? '').toString().trim();
    if (raw.isEmpty) {
      return '';
    }
    if (raw.length >= 16) {
      return raw.substring(0, 16).replaceFirst('T', ' ');
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
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
              '${section.title} (${section.items.length})',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (section.items.isEmpty)
              Text(
                'No ${section.title.toLowerCase()} yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.68)),
              )
            else
              ...section.items.map((Map<String, dynamic> item) {
                final int userId = int.tryParse('${item['user_id'] ?? 0}') ?? 0;
                final String displayName = _displayName(item);
                final String subtitle = section.subtitleBuilder(item).trim();
                final String timeLabel = _timeLabel(item);
                final List<String> imageUrls = AppImageUrls.profileAvatar(
                  avatarUrl: (item['profile_image_url'] ?? item['avatar_url'])
                      .toString(),
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

class _ReactionSummaryRow extends StatelessWidget {
  const _ReactionSummaryRow({required this.post});

  final Map<String, dynamic> post;

  @override
  Widget build(BuildContext context) {
    final List<String> topReactions = _topReactionTypes(post);
    final int likesCount = int.tryParse('${post['likes_count'] ?? 0}') ?? 0;
    final int commentsCount = int.tryParse('${post['comments_count'] ?? 0}') ?? 0;

    return Row(
      children: <Widget>[
        if (topReactions.isNotEmpty)
          SizedBox(
            width: 52,
            height: 22,
            child: Stack(
              children: topReactions
                  .take(3)
                  .toList()
                  .asMap()
                  .entries
                  .map((MapEntry<int, String> entry) {
                return Positioned(
                  left: entry.key * 14,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF171614),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF242321)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _reactionEmojiForType(entry.value),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (topReactions.isNotEmpty) const SizedBox(width: 8),
        Text(
          '$likesCount',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.84),
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Text(
          '$commentsCount comments',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PostActionBar extends StatelessWidget {
  const _PostActionBar({
    required this.post,
    required this.currentReaction,
    required this.isLiked,
    required this.onLike,
    required this.onReact,
    required this.onComment,
    required this.onShare,
  });

  final Map<String, dynamic> post;
  final String currentReaction;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onReact;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final int likesCount = int.tryParse('${post['likes_count'] ?? 0}') ?? 0;
    final int commentsCount = int.tryParse('${post['comments_count'] ?? 0}') ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1814),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _PostActionButton(
              iconText: currentReaction.isNotEmpty
                  ? _reactionEmojiForType(currentReaction)
                  : (isLiked ? _reactionEmojiForType('like') : '\u{1F44D}'),
              label: _reactionLabelForType(currentReaction, isLiked),
              count: likesCount,
              isHighlighted: isLiked,
              onTap: onLike,
              onLongPress: onReact,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PostActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Comment',
              count: commentsCount,
              onTap: onComment,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PostActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  const _PostActionButton({
    this.icon,
    this.iconText,
    required this.label,
    this.count,
    this.isHighlighted = false,
    required this.onTap,
    this.onLongPress,
  });

  final IconData? icon;
  final String? iconText;
  final String label;
  final int? count;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        isHighlighted ? const Color(0xFFD6B878) : Colors.white.withValues(alpha: 0.82);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF2B2218)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF5B482B)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (iconText != null)
              Text(iconText!, style: const TextStyle(fontSize: 18))
            else if (icon != null)
              Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                count != null ? '$label $count' : label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReactionPickerSheet extends StatelessWidget {
  const _ReactionPickerSheet({
    required this.post,
    required this.onSelected,
  });

  final Map<String, dynamic> post;
  final ValueChanged<_ReactionOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final String currentReaction =
        (post['viewer_reaction_type'] ?? '').toString().trim();
    final List<_ReactionOption> reactions = <_ReactionOption>[
      const _ReactionOption(type: 'like', label: 'Like', emoji: '\u{1F44D}'),
      const _ReactionOption(type: 'love', label: 'Love', emoji: '\u{2764}\u{FE0F}'),
      const _ReactionOption(type: 'laugh', label: 'Haha', emoji: '\u{1F602}'),
      const _ReactionOption(type: 'support', label: 'Support', emoji: '\u{1F44F}'),
      const _ReactionOption(type: 'angry', label: 'Angry', emoji: '\u{1F620}'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFF141311),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'React to Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Press and choose the reaction that fits your mood.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: reactions.map((_ReactionOption reaction) {
                final bool isSelected = currentReaction == reaction.type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => onSelected(reaction),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2B2218)
                              : const Color(0xFF1B1A17),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD6B878)
                                : const Color(0xFF3B3125),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(reaction.emoji, style: const TextStyle(fontSize: 28)),
                            const SizedBox(height: 8),
                            Text(
                              reaction.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_reactionCountForType(post, reaction.type)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.54),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

String _reactionEmojiForType(String reactionType) {
  switch (reactionType) {
    case 'love':
      return '\u{2764}\u{FE0F}';
    case 'laugh':
      return '\u{1F602}';
    case 'support':
      return '\u{1F44F}';
    case 'angry':
      return '\u{1F620}';
    case 'like':
    default:
      return '\u{1F44D}';
  }
}

int _reactionCountForType(Map<String, dynamic> post, String reactionType) {
  return int.tryParse('${post['${reactionType}_count'] ?? 0}') ?? 0;
}

String _reactionLabelForType(String reactionType, bool isLiked) {
  switch (reactionType) {
    case 'love':
      return 'Love';
    case 'laugh':
      return 'Haha';
    case 'support':
      return 'Support';
    case 'angry':
      return 'Angry';
    case 'like':
      return 'Like';
    default:
      return isLiked ? 'Like' : 'React';
  }
}

List<String> _topReactionTypes(Map<String, dynamic> post) {
  final List<String> reactionOrder = <String>[
    'like',
    'love',
    'laugh',
    'support',
    'angry',
  ];

  final List<String> result = <String>[];
  for (final String reactionType in reactionOrder) {
    if (_reactionCountForType(post, reactionType) > 0) {
      result.add(reactionType);
    }
  }
  return result;
}

List<Widget> _buildReactionBreakdown(Map<String, dynamic> post) {
  final List<String> reactionOrder = <String>[
    'like',
    'love',
    'laugh',
    'support',
    'angry'
  ];
  final List<Widget> chips = <Widget>[];

  for (final String reactionType in reactionOrder) {
    final int count =
        int.tryParse('${post['${reactionType}_count'] ?? 0}') ?? 0;
    if (count <= 0) {
      continue;
    }
    chips.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1814),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF4E3E28)),
        ),
        child: Text(
          '${_reactionEmojiForType(reactionType)} $count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  return chips;
}

class _WhatsNewComposer extends StatelessWidget {
  const _WhatsNewComposer({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF191815),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF3A2C1B),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome, color: Color(0xFFD6B878)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "What's new in your scent world?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Share text, a photo set, or a short video with your community.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD6B878),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Color(0xFF16120D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateMediaChip extends StatelessWidget {
  const _CreateMediaChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1A17),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: const Color(0xFFD6B878), size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _CommunityVideoPlayer extends StatefulWidget {
  const _CommunityVideoPlayer({
    required this.videoUrl,
    required this.previewUrls,
    required this.label,
  });

  final String videoUrl;
  final List<String> previewUrls;
  final String label;

  @override
  State<_CommunityVideoPlayer> createState() => _CommunityVideoPlayerState();
}

class _CommunityVideoPlayerState extends State<_CommunityVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant _CommunityVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    if (widget.videoUrl.trim().isEmpty) {
      setState(() => _hasError = true);
      return;
    }

    try {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0.0);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isReady = true;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _togglePlayPause() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.setVolume(0.0);
      await controller.pause();
    } else {
      await controller.setVolume(1.0);
      await controller.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _disposeController() async {
    final VideoPlayerController? controller = _controller;
    _controller = null;
    _isReady = false;
    if (controller != null) {
      await controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VideoPlayerController? controller = _controller;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        if (_isReady && controller != null && controller.value.isInitialized)
          GestureDetector(
            onTap: _togglePlayPause,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
                Container(color: Colors.black.withValues(alpha: 0.12)),
              ],
            ),
          )
        else if (widget.previewUrls.isNotEmpty)
          FallbackNetworkImage(
            imageUrls: widget.previewUrls,
            label: widget.label,
            fit: BoxFit.cover,
          )
        else
          Container(color: const Color(0xFF171614)),
        Container(
            color: Colors.black.withValues(alpha: _isReady ? 0.12 : 0.24)),
        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFD6B878),
              child: Icon(
                _isReady && controller != null && controller.value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 42,
                color: const Color(0xFF16120D),
              ),
            ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.46),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              _hasError ? 'Video unavailable' : 'Video',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionOption {
  const _ReactionOption({
    required this.type,
    required this.label,
    required this.emoji,
  });

  final String type;
  final String label;
  final String emoji;
}

class _CreatorCard extends StatelessWidget {
  const _CreatorCard({
    required this.rank,
    required this.creator,
    required this.displayName,
    required this.onFollow,
    required this.onOpenProfile,
    required this.canFollow,
  });

  final int rank;
  final Map<String, dynamic> creator;
  final String displayName;
  final VoidCallback onFollow;
  final VoidCallback onOpenProfile;
  final bool canFollow;

  @override
  Widget build(BuildContext context) {
    final bool isFollowing = '${creator['is_following']}' == '1';
    final List<String> avatarUrls = AppImageUrls.profileAvatar(
      avatarUrl:
          (creator['profile_image_url'] ?? creator['avatar_url']).toString(),
      imagePath: (creator['users_image'] ?? '').toString(),
    );

    return InkWell(
      onTap: onOpenProfile,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF242321),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFD6B878),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Color(0xFF16120D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            avatarUrls.isNotEmpty
                ? ClipOval(
                    child: FallbackNetworkImage(
                      imageUrls: avatarUrls,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      label: displayName,
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3A2C1B),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFD6B878),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '@${(creator['username'] ?? 'fragrance.creator').toString().replaceAll('@', '')}',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.56)),
                  ),
                ],
              ),
            ),
            if (canFollow)
              ElevatedButton(
                onPressed: onFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6B878),
                  foregroundColor: const Color(0xFF16120D),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(isFollowing ? 'Following' : 'Follow'),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171614),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF33281C)),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ),
    );
  }
}
