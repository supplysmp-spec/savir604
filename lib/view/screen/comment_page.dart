import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';

import '../../controler/settings/settings_controller.dart';
import '../../controler/video/comments_controller.dart';
import '../../core/class/crud.dart';
import '../../data/datasource/model/comment_model.dart';

class CommentsPage extends StatefulWidget {
  final int? videoId;
  final int? userId;

  const CommentsPage({super.key, this.videoId, this.userId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late final TextEditingController txt;
  late final FocusNode txtFocus;
  int? replyingToId;
  String? replyingToName;

  @override
  void initState() {
    super.initState();
    txt = TextEditingController();
    txtFocus = FocusNode();
  }

  @override
  void dispose() {
    txt.dispose();
    txtFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final int vid = widget.videoId ?? args['videoId'] ?? 0;
    final int uid = widget.userId ??
        args['userId'] ??
        Get.find<MyServices>().sharedPreferences.getInt('id') ??
        0;

    final String tag = 'comments_$vid';
    final CommentsController controller = Get.put(
      CommentsController(crud: Crud(), videoId: vid, currentUserId: uid),
      tag: tag,
    );

    final SettingsController settings = Get.isRegistered<SettingsController>()
        ? Get.find()
        : Get.put(SettingsController());

    final List<String> currentUserImageCandidates = AppImageUrls.profileAvatar(
      avatarUrl: (settings.userData?['profile_image_url'] ??
              settings.userData?['avatar_url'] ??
              Get.find<MyServices>().sharedPreferences.getString('avatar_url'))
          ?.toString(),
      imagePath: (settings.userData?['users_image'] ??
              Get.find<MyServices>().sharedPreferences.getString('users_image'))
          ?.toString(),
    );
    final String? currentUserImageUrl =
        currentUserImageCandidates.isEmpty ? null : currentUserImageCandidates.first;

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.76,
        minChildSize: 0.48,
        maxChildSize: 0.96,
        builder: (ctx, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0CA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'comments'.tr,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF151515),
                          ),
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.comments.length} ${'comments_items'.tr}',
                          style: const TextStyle(
                            color: Color(0xFF7D7D77),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }

                    if (controller.comments.isEmpty) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: SizedBox(
                          height: 340,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 34,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'no_comments_yet'.tr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 34),
                                child: Text(
                                  'start_conversation_reel'.tr,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF75756F),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                      itemCount: controller.comments.length,
                      itemBuilder: (ctx, index) {
                        final c = controller.comments[index];
                        return _CommentTile(
                          comment: c,
                          currentUserId: controller.currentUserId,
                          currentUserImageUrl: currentUserImageUrl,
                          onReply: () {
                            setState(() {
                              replyingToId = c.commentId;
                              replyingToName = c.usersName;
                              txt.text = '@${c.usersName} ';
                            });
                            FocusScope.of(context).requestFocus(txtFocus);
                          },
                          onLike: () => controller.toggleLikeComment(c.commentId),
                          onDelete: () => controller.deleteComment(c.commentId),
                        );
                      },
                    );
                  }),
                ),
                if (replyingToId != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE6E6E0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${'replying_to'.tr} $replyingToName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              replyingToId = null;
                              replyingToName = null;
                              txt.clear();
                            });
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF666661),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    6,
                    14,
                    MediaQuery.of(context).viewInsets.bottom + 14,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _UserAvatar(
                        name: settings.userData?['users_name']?.toString() ?? 'U',
                        imageUrl: currentUserImageUrl,
                        radius: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE3E3DD)),
                          ),
                          child: TextField(
                            controller: txt,
                            focusNode: txtFocus,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'write_comment'.tr,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Obx(() {
                        return controller.posting.value
                            ? const SizedBox(
                                width: 44,
                                height: 44,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              )
                            : InkWell(
                                onTap: () async {
                                  final text = txt.text.trim();
                                  if (text.isEmpty) return;
                                  await controller.postComment(
                                    text,
                                    parentId: replyingToId,
                                  );
                                  setState(() {
                                    txt.clear();
                                    replyingToId = null;
                                    replyingToName = null;
                                  });
                                  txtFocus.unfocus();
                                },
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF111111),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final int currentUserId;
  final String? currentUserImageUrl;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.currentUserImageUrl,
    required this.onReply,
    required this.onLike,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(
                name: comment.usersName,
                imageUrl: comment.userId == currentUserId
                    ? currentUserImageUrl
                    : null,
                radius: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.usersName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF171717),
                            ),
                          ),
                        ),
                        Text(
                          comment.commentDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8A8A84),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      comment.commentText,
                      style: const TextStyle(
                        color: Color(0xFF40403C),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        InkWell(
                          onTap: onLike,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4EF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite_border_rounded,
                                  size: 16,
                                  color: Color(0xFF1A1A1A),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${comment.commentLikes}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: onReply,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1A1A1A),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text('reply'.tr),
                        ),
                        if (comment.userId == currentUserId)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Color(0xFF8A3B33),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE7E7E1)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _UserAvatar(
                              name: reply.usersName,
                              imageUrl: reply.userId == currentUserId
                                  ? currentUserImageUrl
                                  : null,
                              radius: 16,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reply.usersName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reply.commentText,
                                    style: const TextStyle(
                                      color: Color(0xFF494943),
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (reply.userId == currentUserId)
                              IconButton(
                                onPressed: () => onDeleteReply(context, reply),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: Color(0xFF8A3B33),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              '${reply.commentLikes}',
                              style: const TextStyle(
                                color: Color(0xFF7D7D77),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void onDeleteReply(BuildContext context, CommentModel reply) {
    final CommentsController controller = Get.find<CommentsController>(
      tag: 'comments_${reply.videoId}',
    );
    controller.deleteComment(reply.commentId);
  }
}

class _UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double radius;

  const _UserAvatar({
    required this.name,
    required this.imageUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF111111),
      backgroundImage: imageUrl == null || imageUrl!.isEmpty
          ? null
          : CachedNetworkImageProvider(imageUrl!),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
    );
  }
}
