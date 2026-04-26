import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tks/controler/home/home_controller.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/controler/notification_con.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/controler/settings/settings_controller.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:video_player/video_player.dart';
import 'package:tks/view/notification/notification_page.dart';
import 'package:tks/view/screen/fragrance/fragrance_story_screen.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeControllerImp());
    final palette = AppSurfacePalette.of(context);

    return GetBuilder<HomeControllerImp>(
      builder: (HomeControllerImp controller) {
        final List<ItemsModel> products = controller.isSearch
            ? controller.searchResults
            : controller.items
                .map((dynamic e) =>
                    ItemsModel.fromJson(Map<String, dynamic>.from(e)))
                .toList();

        final List<ItemsModel> featuredProducts = products
            .where((ItemsModel item) => item.itemsIsFeatured == '1')
            .toList();
        final ItemsModel? heroProduct = featuredProducts.isNotEmpty
            ? featuredProducts.first
            : (products.isNotEmpty ? products.first : null);
        final bool isSearching = controller.isSearch;

        return Scaffold(
          backgroundColor: palette.scaffoldBackground,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.screenGradient,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: HandlingDataView(
                    statusRequest: controller.statusRequest,
                    widget: ListView(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
                      children: <Widget>[
                        _HomeTopBar(controller: controller),
                        const SizedBox(height: 16),
                        _LuxurySearchBar(controller: controller),
                        if (!isSearching) ...<Widget>[
                          const SizedBox(height: 20),
                          _StoryStrip(
                              userId: int.tryParse(controller.id ?? '') ?? 0),
                          const SizedBox(height: 20),
                          _HeroBanner(
                            controller: controller,
                            product: heroProduct,
                          ),
                          const SizedBox(height: 30),
                          _SectionHeader(
                            title: 'Categories',
                            actionLabel: '',
                            onTap: controller.categories.isNotEmpty
                                ? () => controller.goToItems(
                                      controller.categories,
                                      0,
                                      '${controller.categories.first['categories_id']}',
                                    )
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _CategoryRail(controller: controller),
                          const SizedBox(height: 28),
                          if (products.isEmpty)
                            const _EmptyProductShelf()
                          else ...<Widget>[
                            _SectionHeader(
                              title: 'Trending Now',
                              actionLabel: 'See All',
                              onTap: controller.categories.isNotEmpty
                                  ? () => controller.goToItems(
                                        controller.categories,
                                        0,
                                        '${controller.categories.first['categories_id']}',
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _HorizontalProductShelf(
                              products: products.take(6).toList(),
                              onTap: controller.goToPageProductDetails,
                            ),
                            const SizedBox(height: 28),
                            const _SectionHeader(
                              title: 'Best Sellers',
                              actionLabel: 'See All',
                              onTap: null,
                            ),
                            const SizedBox(height: 16),
                            _HorizontalProductShelf(
                              products: products.skip(1).take(6).toList(),
                              onTap: controller.goToPageProductDetails,
                            ),
                            const SizedBox(height: 28),
                            const _SectionHeader(
                              title: 'New Arrivals',
                              actionLabel: 'See All',
                              onTap: null,
                            ),
                            const SizedBox(height: 16),
                            _HorizontalProductShelf(
                              products: products.skip(2).take(6).toList(),
                              onTap: controller.goToPageProductDetails,
                            ),
                          ],
                        ] else ...<Widget>[
                          const SizedBox(height: 22),
                          _SearchSummary(
                            query: controller.search?.text.trim() ?? '',
                            count: products.length,
                          ),
                          const SizedBox(height: 18),
                        ],
                        if (isSearching) ...<Widget>[
                          _SectionHeader(
                            title: 'Search Results',
                            actionLabel: 'Clear',
                            onTap: () {
                              controller.search?.clear();
                              controller.checkSearch('');
                            },
                          ),
                          const SizedBox(height: 16),
                          _ProductGrid(
                            products: products,
                            isSearching: isSearching,
                            onTap: controller.goToPageProductDetails,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.controller});

  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    final MyServices services = Get.find<MyServices>();
    final SettingsController settings =
        Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>()
            : Get.put(SettingsController());
    final NotificationController notificationController =
        Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());

    final String username = (controller.username ?? 'Guest').trim();
    final String initial =
        username.isNotEmpty ? username[0].toUpperCase() : 'G';
    final int userId = int.tryParse(controller.id ?? '') ?? 0;
    final List<String> profileImageUrls = AppImageUrls.profileAvatar(
      avatarUrl: (settings.userData?['profile_image_url'] ??
              settings.userData?['avatar_url'] ??
              services.sharedPreferences.getString('avatar_url'))
          ?.toString(),
      imagePath: (settings.userData?['users_image'] ??
              services.sharedPreferences.getString('users_image'))
          ?.toString(),
    );

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Precious',
                style: TextStyle(
                  color: palette.primaryText,
                  fontFamily: 'myfont',
                  fontSize: 22,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Fragrance',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.accent.withValues(alpha: 0.78),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _CircleActionButton(
                icon: Icons.notifications_none_rounded,
                onTap: () => Get.to(() => const NotificationPage()),
              ),
              if (notificationController.unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6B878),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        notificationController.unreadCount > 9
                            ? '9+'
                            : '${notificationController.unreadCount}',
                        style: const TextStyle(
                          color: Color(0xFF1A160F),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: userId <= 0
              ? null
              : () => Get.to(() => ProfilePage(userId: userId)),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.cardAlt,
              border: Border.all(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: profileImageUrls.isEmpty
                ? Image.asset(
                    'assets/images/avatar.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFFE7D09A),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  )
                : Image.network(
                    profileImageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Color(0xFFE7D09A),
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.card,
          border: Border.all(color: palette.border),
        ),
        child: Icon(
          icon,
          color: palette.accent,
          size: 22,
        ),
      ),
    );
  }
}

class _LuxurySearchBar extends StatelessWidget {
  const _LuxurySearchBar({required this.controller});

  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: palette.cardAlt,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            color: palette.tertiaryText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.search,
              style: TextStyle(color: palette.primaryText),
              onChanged: controller.checkSearch,
              onSubmitted: (_) => controller.onSearchItems(),
              decoration: InputDecoration(
                hintText: 'Search fragrances...',
                hintStyle: TextStyle(
                  color: palette.tertiaryText,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryStrip extends StatefulWidget {
  const _StoryStrip({required this.userId});

  final int userId;

  @override
  State<_StoryStrip> createState() => _StoryStripState();
}

class _StoryStripState extends State<_StoryStrip> {
  late final FragranceSocialData _socialData;
  List<Map<String, dynamic>> _stories = <Map<String, dynamic>>[];
  bool _isLoading = true;
  bool _isSubmittingStory = false;

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _loadStories();
  }

  Future<void> _loadStories() async {
    if (widget.userId <= 0) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final List<Map<String, dynamic>> stories =
        await _socialData.getStories(widget.userId);
    if (!mounted) return;
    setState(() {
      _stories = stories;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _ownStories => _stories
      .where((Map<String, dynamic> story) =>
          int.tryParse('${story['user_id']}') == widget.userId)
      .toList();

  List<Map<String, dynamic>> get _followingStories => _stories
      .where((Map<String, dynamic> story) =>
          int.tryParse('${story['user_id']}') != widget.userId)
      .toList();

  List<List<Map<String, dynamic>>> get _followingStoryGroups {
    final Map<String, List<Map<String, dynamic>>> grouped =
        <String, List<Map<String, dynamic>>>{};

    for (final Map<String, dynamic> story in _followingStories) {
      final String userKey = '${story['user_id']}';
      grouped.putIfAbsent(userKey, () => <Map<String, dynamic>>[]).add(story);
    }

    return grouped.values.toList();
  }

  Map<String, dynamic>? get _latestOwnStory =>
      _ownStories.isNotEmpty ? _ownStories.first : null;

  List<String> _storyImageUrls(Map<String, dynamic> story) {
    final String mediaUrl = (story['media_url'] ?? '').toString().trim();
    if (mediaUrl.isEmpty) {
      return const <String>[];
    }
    return AppImageUrls.item(mediaUrl);
  }

  List<String> _storyAvatarUrls(Map<String, dynamic> story) {
    return AppImageUrls.profileAvatar(
      avatarUrl: (story['profile_image_url'] ?? story['avatar_url']).toString(),
      imagePath: (story['users_image'] ?? '').toString(),
    );
  }

  bool _isVideoStory(Map<String, dynamic> story) =>
      (story['story_type'] ?? '').toString().trim().toLowerCase() == 'video';

  Widget _buildStoryPreview(
    Map<String, dynamic> story, {
    required String label,
    List<String> fallbackAvatarUrls = const <String>[],
  }) {
    final List<String> mediaUrls = _storyImageUrls(story);
    final List<String> avatarUrls = fallbackAvatarUrls.isNotEmpty
        ? fallbackAvatarUrls
        : _storyAvatarUrls(story);

    if (mediaUrls.isNotEmpty) {
      if (_isVideoStory(story)) {
        return _StoryVideoPreview(
          videoUrls: mediaUrls,
          label: label,
          fallbackAvatarUrls: avatarUrls,
        );
      }

      return FallbackNetworkImage(
        imageUrls: mediaUrls,
        label: label,
        fit: BoxFit.cover,
      );
    }

    if (avatarUrls.isNotEmpty) {
      return FallbackNetworkImage(
        imageUrls: avatarUrls,
        label: label,
        fit: BoxFit.cover,
      );
    }

    return Image.asset('assets/images/avatar.png', fit: BoxFit.cover);
  }

  Widget _buildOwnStoryPreview() {
    final MyServices services = Get.find<MyServices>();
    final SettingsController settings =
        Get.isRegistered<SettingsController>()
            ? Get.find<SettingsController>()
            : Get.put(SettingsController());
    final List<String> profileImageUrls = AppImageUrls.profileAvatar(
      avatarUrl: (settings.userData?['profile_image_url'] ??
              settings.userData?['avatar_url'] ??
              services.sharedPreferences.getString('avatar_url'))
          ?.toString(),
      imagePath: (settings.userData?['users_image'] ??
              services.sharedPreferences.getString('users_image'))
          ?.toString(),
    );

    if (_latestOwnStory != null) {
      return _buildStoryPreview(
        _latestOwnStory!,
        label: 'Your Story',
        fallbackAvatarUrls: profileImageUrls,
      );
    }

    if (profileImageUrls.isNotEmpty) {
      return FallbackNetworkImage(
        imageUrls: profileImageUrls,
        label: 'Your Story',
        fit: BoxFit.cover,
      );
    }

    return Image.asset('assets/images/avatar.png', fit: BoxFit.cover);
  }

  String _storyLabel(Map<String, dynamic> story) {
    final String displayName = (story['display_name'] ?? '').toString().trim();
    final String username = (story['users_name'] ?? '').toString().trim();
    return displayName.isNotEmpty
        ? displayName
        : (username.isNotEmpty ? username : 'Story');
  }

  String _timeLabel(Map<String, dynamic> story) {
    final String createdAt = (story['created_at'] ?? '').toString().trim();
    if (createdAt.isEmpty || createdAt.length < 16) {
      return 'Now';
    }
    return createdAt.substring(0, 16).replaceFirst('T', ' ');
  }

  Future<void> _openStoryComposer() async {
    if (_isSubmittingStory || widget.userId <= 0) {
      return;
    }

    final TextEditingController textController = TextEditingController();
    final ImagePicker picker = ImagePicker();
    XFile? selectedMedia;

    Future<void> pickStoryMedia(ImageSource source,
        {required bool video}) async {
      final XFile? picked = video
          ? await picker.pickVideo(
              source: source, maxDuration: const Duration(seconds: 30))
          : await picker.pickImage(source: source);
      if (picked != null) {
        selectedMedia = picked;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF12110F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (
            BuildContext modalContext,
            void Function(void Function()) setModalState,
          ) {
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20 + MediaQuery.of(modalContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Add Story',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share a quick fragrance moment with text, image, or video.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.64),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await pickStoryMedia(
                                ImageSource.gallery,
                                video: false,
                              );
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1A17),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFF433627)),
                              ),
                              child: const Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Color(0xFFD6B878),
                                    size: 28,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Choose image',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE8D7B1),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await pickStoryMedia(
                                ImageSource.gallery,
                                video: true,
                              );
                              setModalState(() {});
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B1A17),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFF433627)),
                              ),
                              child: const Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.video_library_outlined,
                                    color: Color(0xFFD6B878),
                                    size: 28,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Choose video',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFE8D7B1),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (selectedMedia != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171614),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF433627)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              selectedMedia!.name
                                          .toLowerCase()
                                          .endsWith('.mp4') ||
                                      selectedMedia!.name
                                          .toLowerCase()
                                          .endsWith('.mov') ||
                                      selectedMedia!.name
                                          .toLowerCase()
                                          .endsWith('.webm')
                                  ? Icons.movie_creation_outlined
                                  : Icons.image_outlined,
                              color: const Color(0xFFD6B878),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedMedia!.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFE8D7B1),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        await pickStoryMedia(ImageSource.camera, video: false);
                        setModalState(() {});
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171614),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF3D3226)),
                        ),
                        child: const Row(
                          children: <Widget>[
                            Icon(
                              Icons.photo_camera_outlined,
                              color: Color(0xFFD6B878),
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Take photo instead',
                              style: TextStyle(
                                color: Color(0xFFE8D7B1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Write a short story...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.34)),
                        filled: true,
                        fillColor: const Color(0xFF1B1A17),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFF433627)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFF433627)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFFD6B878)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (textController.text.trim().isEmpty &&
                              selectedMedia == null) {
                            Get.snackbar(
                              'Story needs content',
                              'Add a caption or choose media first.',
                              backgroundColor: const Color(0xFF2A1616),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          Navigator.of(modalContext).pop();
                          if (!mounted) {
                            return;
                          }

                          setState(() => _isSubmittingStory = true);
                          final Map<String, dynamic> response =
                              await _socialData.createStory(
                            userId: widget.userId,
                            storyText: textController.text.trim(),
                            mediaFile: selectedMedia,
                          );
                          if (!mounted) {
                            return;
                          }

                          setState(() => _isSubmittingStory = false);

                          final bool success = response['status'] == 'success';
                          Get.snackbar(
                            success ? 'Story added' : 'Unable to add story',
                            success
                                ? 'Your story is now live.'
                                : (response['message']?.toString() ??
                                    'Please try again.'),
                            backgroundColor: success
                                ? const Color(0xFF1D2A1D)
                                : const Color(0xFF2A1616),
                            colorText: Colors.white,
                          );

                          if (success) {
                            setState(() => _isLoading = true);
                            await _loadStories();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B878),
                          foregroundColor: const Color(0xFF16120D),
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          _isSubmittingStory
                              ? 'Publishing...'
                              : 'Publish Story',
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

  void _openStoryViewer(
    Map<String, dynamic> story, {
    List<Map<String, dynamic>>? stories,
  }) {
    final String label = _storyLabel(story);
    final List<Map<String, dynamic>> orderedStories = stories ?? <Map<String, dynamic>>[story];
    final int initialIndex = orderedStories.indexWhere(
      (Map<String, dynamic> item) => '${item['story_id']}' == '${story['story_id']}',
    );
    Get.to(
      () => FragranceStoryScreen(
        storyId: int.tryParse('${story['story_id']}') ?? 0,
        viewerId: widget.userId,
        mediaPath: (story['media_url'] ?? '').toString(),
        userName: label,
        storyType: (story['story_type'] ?? 'image').toString(),
        storyText: (story['story_text'] ?? '').toString(),
        timeLabel: _timeLabel(story),
        stories: orderedStories,
        initialIndex: initialIndex < 0 ? 0 : initialIndex,
      ),
    );
  }

  Future<void> _handleOwnStoryTap() async {
    if (_ownStories.isEmpty) {
      await _openStoryComposer();
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF12110F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Your Story',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: Color(0xFFD6B878),
                  ),
                  title: const Text(
                    'View current story',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    _openStoryViewer(
                      _ownStories.first,
                      stories: _ownStories,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFFD6B878),
                  ),
                  title: const Text(
                    'Add new story',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.of(modalContext).pop();
                    _openStoryComposer();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 96,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD6B878),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 1 + _followingStoryGroups.length,
        separatorBuilder: (_, __) => const SizedBox(width: 22),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return InkWell(
              onTap: _handleOwnStoryTap,
              borderRadius: BorderRadius.circular(18),
              child: _StoryBubble(
                label: 'Your Story',
                showAdd: true,
                image: _buildOwnStoryPreview(),
              ),
            );
          }

          final List<Map<String, dynamic>> storyGroup =
              _followingStoryGroups[index - 1];
          final Map<String, dynamic> story = storyGroup.first;
          final String label = _storyLabel(story);
          return InkWell(
            onTap: () => _openStoryViewer(
              story,
              stories: storyGroup,
            ),
            borderRadius: BorderRadius.circular(18),
            child: _StoryBubble(
              label: label,
              image: _buildStoryPreview(
                story,
                label: label,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.label,
    required this.image,
    this.showAdd = false,
  });

  final String label;
  final Widget image;
  final bool showAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xFFD2B679), width: 1.4),
                ),
                child: ClipOval(child: image),
              ),
              if (showAdd)
                Positioned(
                  right: -1,
                  bottom: 3,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD2B679),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 13,
                      color: Color(0xFF17140D),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryVideoPreview extends StatefulWidget {
  const _StoryVideoPreview({
    required this.videoUrls,
    required this.label,
    required this.fallbackAvatarUrls,
  });

  final List<String> videoUrls;
  final String label;
  final List<String> fallbackAvatarUrls;

  @override
  State<_StoryVideoPreview> createState() => _StoryVideoPreviewState();
}

class _StoryVideoPreviewState extends State<_StoryVideoPreview> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    for (final String url in widget.videoUrls) {
      try {
        final VideoPlayerController controller =
            VideoPlayerController.networkUrl(Uri.parse(url));
        await controller.initialize();
        await controller.setVolume(0.0);
        await controller.setLooping(true);
        await controller.play();
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _controller = controller;
          _ready = true;
          _failed = false;
        });
        return;
      } catch (_) {
        continue;
      }
    }

    if (mounted) {
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready && _controller != null && _controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.10)),
          const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      );
    }

    if (widget.fallbackAvatarUrls.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          FallbackNetworkImage(
            imageUrls: widget.fallbackAvatarUrls,
            label: widget.label,
            fit: BoxFit.cover,
          ),
          if (!_failed)
            Container(
              color: Colors.black.withValues(alpha: 0.14),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (_failed)
            Container(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      );
    }

    return Container(
      color: const Color(0xFF1B1A18),
      child: const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.controller,
    required this.product,
  });

  final HomeControllerImp controller;
  final ItemsModel? product;

  @override
  Widget build(BuildContext context) {
    final ItemsModel? featured = product;
    if (featured == null) {
      return const _EmptyHeroBanner();
    }

    final String title = _localizedName(featured);

    return InkWell(
      onTap: () => controller.goToPageProductDetails(featured),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF1A1A1A),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _ProductArtwork(
              item: featured,
              fallbackVisual: _FallbackProductVisual(title: title),
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 18,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Exclusive Collection',
                    style: TextStyle(
                      color: const Color(0xFFD2B679).withValues(alpha: 0.74),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'myfont',
                      fontSize: 24,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Discover luxury redefined',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.74),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedName(ItemsModel item) {
    final String? value =
        Get.locale?.languageCode == 'ar' ? item.itemsNameAr : item.itemsNameEn;
    return value?.trim().isNotEmpty == true
        ? value!.trim()
        : (item.itemsNameEn?.trim().isNotEmpty == true
            ? item.itemsNameEn!.trim()
            : 'Product');
  }
}

class _EmptyHeroBanner extends StatelessWidget {
  const _EmptyHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0xFF2E2618)),
      ),
      child: const Center(
        child: Text(
          'Featured products will appear here',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProductArtwork extends StatelessWidget {
  const _ProductArtwork({
    required this.item,
    required this.fallbackVisual,
    this.fit = BoxFit.cover,
  });

  final ItemsModel? item;
  final Widget fallbackVisual;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ItemsModel? current = item;
    if (current == null || current.galleryImagePaths.isEmpty) {
      return fallbackVisual;
    }

    return FallbackNetworkImage(
      imageUrls:
          current.galleryImagePaths.expand(AppImageUrls.item).toSet().toList(),
      label: current.itemsNameEn,
      fit: fit,
      errorWidget: fallbackVisual,
      placeholder: fallbackVisual,
    );
  }
}

class _FallbackProductVisual extends StatelessWidget {
  const _FallbackProductVisual({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF2A281E),
            Color(0xFF121212),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.local_florist_outlined,
              color: Color(0xFFD2B679),
              size: 34,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 12,
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

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFD2B679).withValues(alpha: 0.72),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF16140D),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SearchSummary extends StatelessWidget {
  const _SearchSummary({
    required this.query,
    required this.count,
  });

  final String query;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.14),
            ),
            child: const Icon(Icons.search_rounded, color: Color(0xFFE9D5AC)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              query.isEmpty
                  ? '$count matching fragrances'
                  : '$count results for "$query"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: palette.primaryText,
              fontFamily: 'myfont',
              fontSize: 25,
            ),
          ),
        ),
        if (actionLabel.isNotEmpty)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Color(0xFFD2B679),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.controller});

  final HomeControllerImp controller;

  @override
  Widget build(BuildContext context) {
    if (controller.categories.isEmpty) {
      return const _EmptyCategoryRail();
    }

    final List<String> categoryLabels =
        controller.categories.take(6).map<String>((dynamic value) {
      final Map<String, dynamic> category = Map<String, dynamic>.from(value);
      return translateDatabase(
            category['categories_name_ar']?.toString(),
            category['categories_name_en']?.toString(),
          ) ??
          'Category';
    }).toList();

    return GridView.builder(
      itemCount: categoryLabels.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 88,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        final bool hasCategory = controller.categories.isNotEmpty;
        final int categoryIndex =
            hasCategory ? index.clamp(0, controller.categories.length - 1) : 0;

        return _CategoryTile(
          title: categoryLabels[index],
          onTap: hasCategory
              ? () => controller.goToItems(
                    controller.categories,
                    categoryIndex,
                    '${controller.categories[categoryIndex]['categories_id']}',
                  )
              : null,
        );
      },
    );
  }
}

class _EmptyCategoryRail extends StatelessWidget {
  const _EmptyCategoryRail();

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Center(
        child: Text(
          'Categories will appear here',
          style: TextStyle(
            color: palette.secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: palette.cardAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFD2B679),
              size: 22,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalProductShelf extends StatelessWidget {
  const _HorizontalProductShelf({
    required this.products,
    required this.onTap,
  });

  final List<ItemsModel> products;
  final void Function(dynamic item) onTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _EmptyProductShelf();
    }

    final List<ItemsModel?> visibleProducts =
        products.map((ItemsModel item) => item).cast<ItemsModel?>().toList();

    return SizedBox(
      height: 294,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (BuildContext context, int index) {
          final ItemsModel? item = visibleProducts[index];
          return _LuxuryProductCard(
            item: item,
            width: 162,
            onTap: item == null ? null : () => onTap(item),
          );
        },
      ),
    );
  }
}

class _EmptyProductShelf extends StatelessWidget {
  const _EmptyProductShelf();

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Container(
      height: 112,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD2B679).withValues(alpha: 0.14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFD2B679),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No products from backend yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Apply the home seed patch or add active items in the database.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.secondaryText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({
    required this.products,
    required this.isSearching,
    required this.onTap,
  });

  final List<ItemsModel> products;
  final bool isSearching;
  final void Function(dynamic item) onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    if (products.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD6B878).withValues(alpha: 0.14),
              ),
              child: Icon(
                isSearching
                    ? Icons.manage_search_rounded
                    : Icons.inventory_2_outlined,
                color: const Color(0xFFE9D5AC),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isSearching
                  ? 'No matching fragrances'
                  : 'No fragrances found yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.primaryText,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try a different perfume name, note, or collection.'
                  : 'New products will appear here as soon as they are available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 740 ? 3 : 2;
        final double ratio = constraints.maxWidth < 380 ? 0.56 : 0.62;

        return GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 16,
            crossAxisSpacing: 14,
            childAspectRatio: ratio,
          ),
          itemBuilder: (BuildContext context, int index) {
            final ItemsModel item = products[index];
            return _LuxuryProductCard(
              item: item,
              width: double.infinity,
              onTap: () => onTap(item),
            );
          },
        );
      },
    );
  }
}

class _LuxuryProductCard extends StatelessWidget {
  const _LuxuryProductCard({
    required this.item,
    required this.width,
    required this.onTap,
  });

  final ItemsModel? item;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ItemsModel? current = item;
    if (current == null) {
      return const SizedBox.shrink();
    }

    final String title = ((Get.locale?.languageCode == 'ar'
                    ? current.itemsNameAr
                    : current.itemsNameEn)
                ?.trim()
                .isNotEmpty ==
            true
        ? (Get.locale?.languageCode == 'ar'
                ? current.itemsNameAr
                : current.itemsNameEn)!
            .trim()
        : 'Product');
    final String family =
        translateDatabase(current.categoriesNameAr, current.categoriesNameEn) ??
            'Category';
    final String price = _finalPrice(current);
    final double rating = current.averageRatingValue;
    final Widget fallbackVisual = _FallbackProductVisual(
      title: title,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 166,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _ProductArtwork(
                    item: current,
                    fallbackVisual: fallbackVisual,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _SoftPill(
                      label: current.itemsBadge?.trim().isNotEmpty == true
                          ? current.itemsBadge!.trim()
                          : 'Featured',
                    ),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.20),
                        border: Border.all(
                          color:
                              const Color(0xFFD2B679).withValues(alpha: 0.34),
                        ),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 17,
                        color: const Color(0xFFD2B679).withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              family,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                const Icon(Icons.star_rounded,
                    color: Color(0xFFD2B679), size: 14),
                const SizedBox(width: 4),
                Text(
                  rating > 0 ? rating.toStringAsFixed(1) : '0.0',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (current.ratingsCountValue > 0) ...<Widget>[
                  const SizedBox(width: 5),
                  Text(
                    '(${current.ratingsCountValue})',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFD2B679),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _finalPrice(ItemsModel item) {
    final double discounted =
        double.tryParse(item.itemsDiscountPrice ?? '') ?? 0;
    if (discounted > 0) {
      return CurrencyFormatter.egp(discounted);
    }

    final double base = double.tryParse(item.itemsPrice ?? '0') ?? 0;
    final double discount = double.tryParse(item.itemsDiscount ?? '0') ?? 0;
    final double finalValue = base - (base * discount / 100);
    return CurrencyFormatter.egp(finalValue);
  }
}
