import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class SupportHome extends StatefulWidget {
  const SupportHome({
    super.key,
    required this.userId,
    this.initialConversationId,
    this.initialPeerUserId,
  });

  final int userId;
  final int? initialConversationId;
  final int? initialPeerUserId;

  @override
  State<SupportHome> createState() => _SupportHomeState();
}

class _SupportHomeState extends State<SupportHome> {
  late final FragranceSocialData _socialData;
  late final int _currentUserId;

  List<Map<String, dynamic>> _conversations = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _following = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _didHandleInitialChatTarget = false;

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _currentUserId = Get.find<MyServices>().sharedPreferences.getInt('id') ?? widget.userId;
    _loadChatData();
  }

  Future<void> _loadChatData() async {
    setState(() => _isLoading = true);
    final List<Map<String, dynamic>> conversations =
        await _socialData.getConversations(_currentUserId);
    final List<Map<String, dynamic>> following = await _socialData.getFollowList(
      userId: _currentUserId,
      viewerId: _currentUserId,
      mode: 'following',
    );

    if (!mounted) return;
    setState(() {
      _conversations = conversations;
      _following = following;
      _isLoading = false;
    });
    _maybeOpenInitialChatTarget();
  }

  String _displayName(Map<String, dynamic> user) {
    return (user['peer_display_name'] ??
            user['display_name'] ??
            user['peer_name'] ??
            user['users_name'] ??
            'Member')
        .toString();
  }

  String _username(Map<String, dynamic> user) {
    return '@${((user['peer_username'] ?? user['username'] ?? user['users_name'] ?? 'member').toString()).replaceAll('@', '')}';
  }

  String _imageUrl(Map<String, dynamic> user) {
    final List<String> imageCandidates = AppImageUrls.profileAvatar(
      avatarUrl: (user['peer_profile_image_url'] ??
              user['peer_avatar_url'] ??
              user['avatar_url'] ??
              user['profile_image_url'])
          .toString(),
      imagePath: (user['peer_image'] ?? user['users_image']).toString(),
    );
    return imageCandidates.isEmpty ? '' : imageCandidates.first;
  }

  List<String> _imageCandidates(Map<String, dynamic> user) {
    return AppImageUrls.profileAvatar(
      avatarUrl: (user['peer_profile_image_url'] ??
              user['peer_avatar_url'] ??
              user['avatar_url'] ??
              user['profile_image_url'])
          .toString(),
      imagePath: (user['peer_image'] ?? user['users_image']).toString(),
    );
  }

  String _lastMessage(Map<String, dynamic> item) {
    final String value = (item['last_message'] ?? '').toString().trim();
    if (value.isEmpty) {
      return 'Start a new fragrance conversation';
    }
    return value;
  }

  void _openProfile(Map<String, dynamic> user) {
    final int userId = int.tryParse('${user['peer_user_id'] ?? user['users_id']}') ?? 0;
    if (userId <= 0) return;
    Get.to(() => ProfilePage(userId: userId));
  }

  Future<void> _openOrCreateChat(Map<String, dynamic> user) async {
    final int userId = int.tryParse('${user['users_id'] ?? user['peer_user_id']}') ?? 0;
    if (userId <= 0 || userId == _currentUserId) {
      return;
    }

    Map<String, dynamic>? conversation = _conversations.cast<Map<String, dynamic>?>().firstWhere(
          (Map<String, dynamic>? item) => item != null && '${item['peer_user_id']}' == '$userId',
          orElse: () => null,
        );

    if (conversation == null) {
      final Map<String, dynamic> response = await _socialData.createConversation(
        userOneId: _currentUserId,
        userTwoId: userId,
      );

      if ((response['status'] ?? '') != 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text((response['message'] ?? 'Unable to start chat').toString())),
        );
        return;
      }

      await _loadChatData();
      final int conversationId = int.tryParse('${response['conversation_id']}') ?? 0;
      conversation = _conversations.cast<Map<String, dynamic>?>().firstWhere(
            (Map<String, dynamic>? item) =>
                item != null && '${item['conversation_id']}' == '$conversationId',
            orElse: () => null,
          );
    }

    if (conversation == null) {
      return;
    }

    if (!mounted) return;
    await Get.to(
      () => _ConversationScreen(
        currentUserId: _currentUserId,
        conversation: conversation!,
        socialData: _socialData,
      ),
    );
    await _loadChatData();
  }

  Future<void> _maybeOpenInitialChatTarget() async {
    if (_didHandleInitialChatTarget || _isLoading || !mounted) {
      return;
    }

    final int targetConversationId = widget.initialConversationId ?? 0;
    final int targetPeerUserId = widget.initialPeerUserId ?? 0;

    if (targetConversationId <= 0 && targetPeerUserId <= 0) {
      return;
    }

    _didHandleInitialChatTarget = true;

    Map<String, dynamic>? conversation;
    if (targetConversationId > 0) {
      conversation = _conversations.cast<Map<String, dynamic>?>().firstWhere(
            (Map<String, dynamic>? item) =>
                item != null && '${item['conversation_id']}' == '$targetConversationId',
            orElse: () => null,
          );
    }

    if (conversation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await Get.to(
          () => _ConversationScreen(
            currentUserId: _currentUserId,
            conversation: conversation!,
            socialData: _socialData,
          ),
        );
        if (!mounted) return;
        await _loadChatData();
      });
      return;
    }

    if (targetPeerUserId > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _openOrCreateChat(<String, dynamic>{'users_id': '$targetPeerUserId'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _ChatPatternBackground()),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD6B878)),
                  )
                : RefreshIndicator(
                    color: const Color(0xFFD6B878),
                    backgroundColor: const Color(0xFF181715),
                    onRefresh: _loadChatData,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
                      children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Chats',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'myfont',
                              fontSize: 30,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _loadChatData,
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF151515),
                              border: Border.all(color: const Color(0xFF2E261B)),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFFD6B878),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_following.isNotEmpty) ...<Widget>[
                      const Text(
                        'Following',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'myfont',
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 106,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _following.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> user = _following[index];
                            return InkWell(
                              onTap: () => _openOrCreateChat(user),
                              onLongPress: () => _openProfile(user),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 92,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B1A17),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFF3B3125)),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2A2722),
                                        shape: BoxShape.circle,
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: FallbackNetworkImage(
                                        imageUrls: _imageCandidates(user),
                                        label: _displayName(user),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _displayName(user),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                    const Text(
                      'All Chats',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_conversations.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171614),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF33281C)),
                        ),
                        child: Center(
                          child: Text(
                            'No chats yet.\nTap one of the users you follow to start chatting.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              height: 1.6,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._conversations.map(
                        (Map<String, dynamic> conversation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _openOrCreateChat(conversation),
                            onLongPress: () => _openProfile(conversation),
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1A17),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFF3B3125)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2A2722),
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FallbackNetworkImage(
                                      imageUrls: _imageCandidates(conversation),
                                      label: _displayName(conversation),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          _displayName(conversation),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _username(conversation),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.48),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _lastMessage(conversation),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.66),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if ((int.tryParse('${conversation['unread_count']}') ?? 0) > 0)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFD6B878),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${conversation['unread_count']}',
                                        style: const TextStyle(
                                          color: Color(0xFF16120D),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.white38,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConversationScreen extends StatefulWidget {
  const _ConversationScreen({
    required this.currentUserId,
    required this.conversation,
    required this.socialData,
  });

  final int currentUserId;
  final Map<String, dynamic> conversation;
  final FragranceSocialData socialData;

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _refreshTimer;

  int get _conversationId => int.tryParse('${widget.conversation['conversation_id']}') ?? 0;

  String get _displayName => (widget.conversation['peer_display_name'] ??
          widget.conversation['display_name'] ??
          widget.conversation['peer_name'] ??
          'Member')
      .toString();

  String get _imageUrl {
    final List<String> imageCandidates = AppImageUrls.profileAvatar(
      avatarUrl: (widget.conversation['peer_profile_image_url'] ??
              widget.conversation['peer_avatar_url'] ??
              widget.conversation['avatar_url'] ??
              widget.conversation['profile_image_url'])
          .toString(),
      imagePath: (widget.conversation['peer_image'] ?? widget.conversation['users_image'])
          .toString(),
    );
    return imageCandidates.isEmpty ? '' : imageCandidates.first;
  }

  List<String> get _imageCandidates => AppImageUrls.profileAvatar(
        avatarUrl: (widget.conversation['peer_profile_image_url'] ??
                widget.conversation['peer_avatar_url'] ??
                widget.conversation['avatar_url'] ??
                widget.conversation['profile_image_url'])
            .toString(),
        imagePath: (widget.conversation['peer_image'] ?? widget.conversation['users_image'])
            .toString(),
      );

  int get _peerUserId =>
      int.tryParse('${widget.conversation['peer_user_id'] ?? widget.conversation['users_id']}') ?? 0;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(silent: true);
    });
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (_conversationId <= 0) {
      return;
    }

    if (!silent && mounted) {
      setState(() => _isLoading = true);
    }

    final List<Map<String, dynamic>> messages = await widget.socialData.getConversationMessages(
      conversationId: _conversationId,
      userId: widget.currentUserId,
    );
    if (!mounted) return;

    final bool hasChanged = _messages.length != messages.length ||
        !_sameMessageTail(_messages, messages);

    setState(() {
      _messages = messages;
      _isLoading = false;
    });

    if (hasChanged || !silent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToBottom();
      });
    }
  }

  Future<void> _sendMessage([String? quickMessage]) async {
    final String text = (quickMessage ?? _messageController.text).trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final Map<String, dynamic> response = await widget.socialData.sendConversationMessage(
      conversationId: _conversationId,
      senderId: widget.currentUserId,
      message: text,
    );

    if ((response['status'] ?? '') == 'success') {
      _messageController.clear();
      await _loadMessages();
    }

    if (!mounted) return;
    setState(() => _isSending = false);
  }

  String _messageTime(Map<String, dynamic> message) {
    final String createdAt = (message['created_at'] ?? '').toString().trim();
    if (createdAt.isEmpty || createdAt.length < 16) {
      return 'Now';
    }
    return createdAt.substring(11, 16);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _sameMessageTail(
    List<Map<String, dynamic>> current,
    List<Map<String, dynamic>> next,
  ) {
    if (current.isEmpty && next.isEmpty) {
      return true;
    }
    if (current.isEmpty || next.isEmpty) {
      return false;
    }

    final Map<String, dynamic> currentLast = current.last;
    final Map<String, dynamic> nextLast = next.last;
    return '${currentLast['message_id'] ?? currentLast['created_at']}_${currentLast['message']}' ==
        '${nextLast['message_id'] ?? nextLast['created_at']}_${nextLast['message']}';
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _ChatPatternBackground()),
          SafeArea(
            child: Column(
              children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Row(
                children: <Widget>[
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: Get.back,
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _peerUserId > 0 ? () => Get.to(() => ProfilePage(userId: _peerUserId)) : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD6B878),
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FallbackNetworkImage(
                        imageUrls: _imageCandidates,
                        label: _displayName,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _peerUserId > 0 ? () => Get.to(() => ProfilePage(userId: _peerUserId)) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'myfont',
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Connected',
                            style: TextStyle(
                              color: Color(0xFFD6B878),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFD6B878)),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> message = _messages[index];
                        final bool isMine =
                            '${message['sender_id']}' == '${widget.currentUserId}';
                        return Align(
                          alignment:
                              isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.74,
                            ),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xFFD6B878)
                                  : const Color(0xFF2C2B29),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  (message['message'] ?? '').toString(),
                                  style: TextStyle(
                                    color: isMine
                                        ? const Color(0xFF16120D)
                                        : Colors.white,
                                    fontSize: 16,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _messageTime(message),
                                  style: TextStyle(
                                    color: (isMine
                                            ? const Color(0xFF16120D)
                                            : Colors.white)
                                        .withValues(alpha: 0.58),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  _quickReply('Recommend a perfume'),
                  const SizedBox(width: 10),
                  _quickReply('Track my order'),
                  const SizedBox(width: 10),
                  _quickReply('Gift suggestions'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF090909),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD6B878)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: Color(0xFFD6B878),
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB89B5E),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _isSending ? null : _sendMessage,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF090909),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD6B878)),
                      ),
                      child: _isSending
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFD6B878),
                              ),
                            )
                          : const Icon(
                              Icons.send_outlined,
                              color: Color(0xFFD6B878),
                            ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickReply(String text) {
    return InkWell(
      onTap: () => _sendMessage(text),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF090909),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD6B878)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD6B878),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF151515),
          border: Border.all(color: const Color(0xFF2E261B)),
        ),
        child: Icon(icon, color: const Color(0xFFD6B878), size: 18),
      ),
    );
  }
}

class _ChatPatternBackground extends StatelessWidget {
  const _ChatPatternBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF060606),
            Color(0xFF0B0A08),
            Color(0xFF12100C),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _ChatPatternPainter(),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.82, -0.95),
              radius: 1.18,
              colors: <Color>[
                const Color(0xFFD6B878).withValues(alpha: 0.12),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()
      ..color = const Color(0xFFD6B878).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint ringPaint = Paint()
      ..color = const Color(0xFFD6B878).withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    const double spacing = 34;
    for (double x = 18; x < size.width; x += spacing) {
      for (double y = 24; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.15, dotPaint);
      }
    }

    for (double y = 84; y < size.height; y += 148) {
      final Path path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(size.width * 0.28, y - 20, size.width * 0.5, y)
        ..quadraticBezierTo(size.width * 0.72, y + 20, size.width, y - 6);
      canvas.drawPath(path, linePaint);
    }

    canvas.drawCircle(Offset(size.width - 42, 94), 28, ringPaint);
    canvas.drawCircle(Offset(34, size.height * 0.74), 22, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
