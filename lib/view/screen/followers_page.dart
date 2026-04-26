import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/constant/imsgesassets.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/linkapi/linkapi.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({
    super.key,
    required this.userId,
    required this.viewerId,
    this.mode = 'followers',
    this.highlightUserId,
    this.title,
  });

  final int userId;
  final int viewerId;
  final String mode;
  final int? highlightUserId;
  final String? title;

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late final FragranceSocialData _socialData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = <Map<String, dynamic>>[];

  bool get _isFollowersMode => widget.mode == 'followers';

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _socialData.getFollowList(
        userId: widget.userId,
        viewerId: widget.viewerId,
        mode: widget.mode,
      );
      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.title ?? (_isFollowersMode ? 'Followers' : 'Following');

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
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
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'myfont',
                            fontSize: 28,
                          ),
                        ),
                        if (widget.highlightUserId != null && _isFollowersMode)
                          Text(
                            'New follower highlighted below',
                            style: TextStyle(
                              color: const Color(0xFFD6B878)
                                  .withValues(alpha: 0.88),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD6B878),
                backgroundColor: const Color(0xFF1A1A1A),
                onRefresh: _loadUsers,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD6B878)),
      );
    }

    if (_users.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          const SizedBox(height: 120),
          Icon(
            _isFollowersMode
                ? Icons.group_outlined
                : Icons.person_add_alt_1_outlined,
            color: Colors.white.withValues(alpha: 0.35),
            size: 54,
          ),
          const SizedBox(height: 16),
          Text(
            _isFollowersMode ? 'No followers yet' : 'Not following anyone yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final user = _users[index];
        final int userId = int.tryParse('${user['users_id']}') ?? 0;
        final bool isHighlighted =
            widget.highlightUserId != null && widget.highlightUserId == userId;
        final List<String> imageUrls = _imageUrlsFor(user);
        final String bio = (user['bio'] ?? '').toString().trim();

        return InkWell(
          onTap: userId <= 0
              ? null
              : () => Get.to(() => ProfilePage(userId: userId)),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF332913)
                  : const Color(0xFF1B1A17),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFFD6B878)
                    : const Color(0xFF3B3125),
                width: isHighlighted ? 1.4 : 1,
              ),
              boxShadow: isHighlighted
                  ? <BoxShadow>[
                      BoxShadow(
                        color: const Color(0xFFD6B878).withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2722),
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrls.isNotEmpty
                      ? FallbackNetworkImage(
                          imageUrls: imageUrls,
                          label: (user['display_name'] ??
                                  user['users_name'] ??
                                  'User')
                              .toString(),
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                          errorWidget: Image.asset(
                            AppImageAsset.avatar,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          ),
                          placeholder: Image.asset(
                            AppImageAsset.avatar,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          ),
                        )
                      : Image.asset(
                          AppImageAsset.avatar,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              (user['display_name'] ??
                                      user['users_name'] ??
                                      'User #$userId')
                                  .toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isHighlighted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6B878),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'New',
                                style: TextStyle(
                                  color: Color(0xFF16120D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '@${((user['username'] ?? user['users_name'] ?? '$userId').toString()).replaceAll('@', '')}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (bio.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white30,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _imageUrlsFor(Map<String, dynamic> user) {
    final List<String> candidates = AppImageUrls.profileAvatar(
      avatarUrl: (user['profile_image_url'] ?? user['avatar_url'])?.toString(),
      imagePath: user['users_image']?.toString(),
    );

    if (candidates.isNotEmpty) {
      return candidates;
    }

    final String fallbackImageName = (user['users_image'] ?? '').toString();
    if (fallbackImageName.isEmpty) {
      return const <String>[];
    }

    return <String>[
      AppLink.normalizeUrl(
          '${AppLink.server}/uploads/users/img/$fallbackImageName'),
    ];
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
