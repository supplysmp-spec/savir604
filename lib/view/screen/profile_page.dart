import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';
import 'package:tks/controler/settings/settings_controller.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/constant/imsgesassets.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';
import 'package:tks/linkapi/linkapi.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});

  final int userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FragranceSocialData _socialData;
  late final int _viewerId;

  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> savedPerfumes = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> customPerfumes = <Map<String, dynamic>>[];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _socialData = FragranceSocialData(Get.find<Crud>());
    _viewerId =
        Get.find<MyServices>().sharedPreferences.getInt('id') ?? widget.userId;
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
        _socialData.getProfile(userId: widget.userId, viewerId: _viewerId),
        _socialData.getSavedPerfumes(widget.userId),
        _socialData.getCustomPerfumes(
          viewerId: _viewerId,
          mode: widget.userId == _viewerId ? 'mine' : 'user',
          userId: widget.userId,
        ),
      ]).timeout(const Duration(seconds: 20));

      final Map<String, dynamic> profileResponse =
          Map<String, dynamic>.from(results[0] as Map);

      if (!mounted) return;
      setState(() {
        userData = profileResponse['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(profileResponse['data'] as Map)
            : null;
        savedPerfumes = (results[1] as List<dynamic>)
            .map((dynamic e) => Map<String, dynamic>.from(e as Map))
            .toList();
        customPerfumes = (results[2] as List<dynamic>)
            .map((dynamic e) => Map<String, dynamic>.from(e as Map))
            .toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  bool get _isOwnProfile => widget.userId == _viewerId;
  bool get _isFollowingUser => '${userData?['is_following']}' == '1';

  Future<void> _toggleFollowUser() async {
    if (_isOwnProfile || widget.userId <= 0 || _viewerId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.toggleFollow(
      followerUserId: _viewerId,
      followedUserId: widget.userId,
    );

    if ((response['status'] ?? '') != 'success') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              (response['message'] ?? 'unable_update_follow_status'.tr)
                  .toString()),
        ),
      );
      return;
    }

    await getProfile();
  }

  Future<void> _messageUser() async {
    if (_isOwnProfile ||
        !_isFollowingUser ||
        widget.userId <= 0 ||
        _viewerId <= 0) {
      return;
    }

    final Map<String, dynamic> response = await _socialData.createConversation(
      userOneId: _viewerId,
      userTwoId: widget.userId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (response['status'] ?? '') == 'success'
              ? 'chat_ready_open_from_chat'.tr
              : (response['message'] ?? 'unable_start_chat'.tr).toString(),
        ),
      ),
    );
  }

  Future<void> _openSocialSheet(String mode) async {
    final List<Map<String, dynamic>> users = await _socialData.getFollowList(
      userId: widget.userId,
      viewerId: _viewerId,
      mode: mode,
    );

    if (!mounted) return;

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mode == 'followers'
                      ? 'followers_label'.tr
                      : 'following_label'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'myfont',
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 14),
                if (users.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'no_users_found_yet'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> user = users[index];
                        final int userId =
                            int.tryParse('${user['users_id']}') ?? 0;
                        final bool canChat = '${user['is_following']}' == '1' &&
                            userId != _viewerId;
                        final List<String> imageUrls =
                            AppImageUrls.profileAvatar(
                          avatarUrl:
                              (user['profile_image_url'] ?? user['avatar_url'])
                                  ?.toString(),
                          imagePath: user['users_image']?.toString(),
                        );

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1A17),
                            borderRadius: BorderRadius.circular(20),
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
                                child: imageUrls.isNotEmpty
                                    ? FallbackNetworkImage(
                                        imageUrls: imageUrls,
                                        label: (user['display_name'] ??
                                                user['users_name'] ??
                                                'User')
                                            .toString(),
                                        fit: BoxFit.cover,
                                        width: 48,
                                        height: 48,
                                        errorWidget: Image.asset(
                                          AppImageAsset.avatar,
                                          fit: BoxFit.cover,
                                          width: 48,
                                          height: 48,
                                        ),
                                        placeholder: Image.asset(
                                          AppImageAsset.avatar,
                                          fit: BoxFit.cover,
                                          width: 48,
                                          height: 48,
                                        ),
                                      )
                                    : Image.asset(
                                        AppImageAsset.avatar,
                                        fit: BoxFit.cover,
                                        width: 48,
                                        height: 48,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: userId <= 0
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                          Get.to(() =>
                                              ProfilePage(userId: userId));
                                        },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        (user['display_name'] ??
                                                user['users_name'] ??
                                                'User #$userId')
                                            .toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '@${((user['username'] ?? user['users_name'] ?? '$userId').toString()).replaceAll('@', '')}',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.58),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (canChat)
                                TextButton(
                                  onPressed: () async {
                                    final Map<String, dynamic> response =
                                        await _socialData.createConversation(
                                      userOneId: _viewerId,
                                      userTwoId: userId,
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          (response['status'] ?? '') ==
                                                  'success'
                                              ? 'chat_ready_short'.tr
                                              : (response['message'] ??
                                                      'unable_start_chat'.tr)
                                                  .toString(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'message_label'.tr,
                                    style: TextStyle(color: Color(0xFFD6B878)),
                                  ),
                                ),
                            ],
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

  Future<void> uploadImage(File imageFile) async {
    final Uri url = Uri.parse(AppLink.userProfileUploadImage);
    final String oldImageUrl = _profileImageUrlFor(
      userData,
      includeStoredFallback: _isOwnProfile,
    );

    final http.MultipartRequest request = http.MultipartRequest('POST', url);
    request.fields['user_id'] = widget.userId.toString();
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    final http.StreamedResponse response = await request.send();
    final String responseBody = await response.stream.bytesToString();
    dynamic data;
    try {
      data = json.decode(responseBody);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'image_upload_failed_invalid_response'.tr} (${response.statusCode})',
          ),
        ),
      );
      return;
    }

    if (data['status'] == 'success') {
      final String uploadedUrl =
          AppLink.normalizeUrl((data['url'] ?? '').toString());
      final String uploadedName = (data['name'] ?? '').toString();

      setState(() {
        userData ??= <String, dynamic>{};
        userData!['users_image'] = uploadedName;
        userData!['avatar_url'] = uploadedUrl;
        userData!['profile_image_url'] = uploadedUrl;
      });

      if (Get.isRegistered<SettingsController>()) {
        final SettingsController settingsCtrl = Get.find<SettingsController>();
        settingsCtrl.userData ??= <String, dynamic>{};
        settingsCtrl.userData!['users_image'] = uploadedName;
        settingsCtrl.userData!['avatar_url'] = uploadedUrl;
        settingsCtrl.userData!['profile_image_url'] = uploadedUrl;
        settingsCtrl.update();
      }

      final MyServices myServices = Get.find<MyServices>();
      await myServices.sharedPreferences.setString('users_image', uploadedName);
      await myServices.sharedPreferences.setString('avatar_url', uploadedUrl);

      if (uploadedUrl.isNotEmpty) {
        await CachedNetworkImage.evictFromCache(uploadedUrl);
      }
      if (oldImageUrl.isNotEmpty && oldImageUrl != uploadedUrl) {
        await CachedNetworkImage.evictFromCache(oldImageUrl);
      }

      await getProfile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_photo_updated'.tr)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${'image_upload_failed_prefix'.tr}: ${data['message'] ?? 'unknown_error'.tr}')),
      );
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await uploadImage(File(picked.path));
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String username,
    required String bio,
  }) async {
    final Map<String, dynamic> response = await _socialData.updateProfile(
      userId: widget.userId,
      displayName: displayName,
      username: username,
      bio: bio,
      avatarUrl: (userData?['avatar_url'] ?? '').toString(),
      coverUrl: (userData?['cover_url'] ?? '').toString(),
      gender: (userData?['gender'] ?? '').toString(),
      favoriteFamily: (userData?['favorite_family'] ?? '').toString(),
      profileVisibility:
          (userData?['profile_visibility'] ?? 'public').toString(),
      isCreator: '${userData?['is_creator']}' == '1',
    );

    if ((response['status'] ?? '') != 'success') {
      throw Exception(
          (response['message'] ?? 'Unable to update profile').toString());
    }

    final MyServices myServices = Get.find<MyServices>();
    await myServices.sharedPreferences.setString('display_name', displayName);
    await myServices.sharedPreferences.setString('username', username);
    await myServices.sharedPreferences.setString('users_name', displayName);

    if (Get.isRegistered<SettingsController>()) {
      final SettingsController settingsCtrl = Get.find<SettingsController>();
      settingsCtrl.userData ??= <String, dynamic>{};
      settingsCtrl.userData!['display_name'] = displayName;
      settingsCtrl.userData!['users_name'] = displayName;
      settingsCtrl.userData!['username'] = username;
      settingsCtrl.update();
    }

    await getProfile();
  }

  String _profileImageUrlFor(Map<String, dynamic>? source,
      {bool includeStoredFallback = false}) {
    final MyServices services = Get.find<MyServices>();
    final List<String> candidates = AppImageUrls.profileAvatar(
      avatarUrl: (source?['profile_image_url'] ??
              source?['avatar_url'] ??
              (includeStoredFallback
                  ? services.sharedPreferences.getString('avatar_url')
                  : null))
          ?.toString(),
      imagePath: (source?['users_image'] ??
              (includeStoredFallback
                  ? services.sharedPreferences.getString('users_image')
                  : null))
          ?.toString(),
    );
    return candidates.isEmpty ? '' : candidates.first;
  }

  Future<void> showEditProfileDialog() async {
    final TextEditingController nameController = TextEditingController(
      text: (userData?['display_name'] ?? userData?['users_name'] ?? '')
          .toString(),
    );
    final TextEditingController usernameController = TextEditingController(
      text: (userData?['username'] ?? '').toString(),
    );
    final TextEditingController bioController = TextEditingController(
      text: (userData?['bio'] ?? '').toString(),
    );
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext,
              void Function(void Function()) setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1B1A18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(
                'edit_profile'.tr,
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dialogFieldDecoration(
                          'display_name'.tr, Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dialogFieldDecoration(
                          'username_label'.tr, Icons.alternate_email_rounded),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: _dialogFieldDecoration(
                          'bio_label'.tr, Icons.auto_awesome_outlined),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('cancel_label'.tr),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final String name = nameController.text.trim();
                          final String username =
                              usernameController.text.trim();
                          final String bio = bioController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'please_enter_display_name'.tr)),
                            );
                            return;
                          }

                          setStateDialog(() => isSaving = true);
                          try {
                            await updateProfile(
                              displayName: name,
                              username: username,
                              bio: bio,
                            );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } on TimeoutException {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('request_timed_out'.tr)),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e
                                    .toString()
                                    .replaceFirst('Exception: ', '')),
                              ),
                            );
                          } finally {
                            if (dialogContext.mounted) {
                              setStateDialog(() => isSaving = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6B878),
                    foregroundColor: const Color(0xFF16120D),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogFieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.60)),
      prefixIcon: Icon(icon, color: const Color(0xFFD6B878)),
      filled: true,
      fillColor: const Color(0xFF121212),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = Get.find<MyServices>();
    final List<String> profileImageUrls = AppImageUrls.profileAvatar(
      avatarUrl: (userData?['profile_image_url'] ??
              userData?['avatar_url'] ??
              (_isOwnProfile
                  ? services.sharedPreferences.getString('avatar_url')
                  : null))
          ?.toString(),
      imagePath: (userData?['users_image'] ??
              (_isOwnProfile
                  ? services.sharedPreferences.getString('users_image')
                  : null))
          ?.toString(),
    );
    final String rawDisplayName = (userData?['display_name'] ??
            userData?['users_name'] ??
            (_isOwnProfile
                ? services.sharedPreferences.getString('display_name')
                : null) ??
            (_isOwnProfile
                ? services.sharedPreferences.getString('users_name')
                : null) ??
            '')
        .toString()
        .trim();
    final String rawUsername = (userData?['username'] ??
            (_isOwnProfile
                ? services.sharedPreferences.getString('username')
                : null) ??
            '')
        .toString()
        .trim()
        .replaceAll('@', '');
    final String favoriteFamily =
        (userData?['favorite_family'] ?? '').toString().trim();
    final String userName =
        rawDisplayName.isNotEmpty ? rawDisplayName : 'User #${widget.userId}';
    final String? subtitle = favoriteFamily.isNotEmpty ? favoriteFamily : null;
    final String? profileUsername =
        rawUsername.isNotEmpty ? '@$rawUsername' : null;
    final String bio = (userData?['bio'] ?? '').toString().trim();
    final String email = (userData?['users_email'] ?? '').toString().trim();
    final String phone = (userData?['users_phone'] ?? '').toString().trim();
    final String visibility =
        (userData?['profile_visibility'] ?? '').toString().trim();
    final int followersCount =
        int.tryParse('${userData?['followers_count'] ?? 0}') ?? 0;
    final int followingCount =
        int.tryParse('${userData?['following_count'] ?? 0}') ?? 0;
    final int postsCount =
        int.tryParse('${userData?['posts_count'] ?? 0}') ?? 0;
    final int savedCount = savedPerfumes.length;
    final bool hasSavedPerfumes = savedPerfumes.isNotEmpty;

    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090909),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD6B878)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFD6B878),
          backgroundColor: const Color(0xFF181715),
          onRefresh: getProfile,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
            children: <Widget>[
              Row(
                children: <Widget>[
                  _profileCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      if (Get.previousRoute.isNotEmpty) {
                        Get.back();
                      } else {
                        Get.offAllNamed(AppRoutes.homepage);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'profile_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 27,
                      ),
                    ),
                  ),
                  _isOwnProfile
                      ? _profileCircleButton(
                          icon: Icons.settings_outlined,
                          onTap: () => Get.toNamed(AppRoutes.set),
                        )
                      : const SizedBox(width: 44, height: 44),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1713), Color(0xFF111111)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0xFF3B3125)),
                ),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          GestureDetector(
                            onTap: _isOwnProfile ? pickImage : null,
                            child: Container(
                              width: 112,
                              height: 112,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFD6B878), width: 1.4),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0xFFD6B878)
                                        .withValues(alpha: 0.16),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF23211E),
                                  shape: BoxShape.circle,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: profileImageUrls.isNotEmpty
                                    ? FallbackNetworkImage(
                                        imageUrls: profileImageUrls,
                                        label: userName,
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                        errorWidget: Image.asset(
                                          AppImageAsset.avatar,
                                          fit: BoxFit.cover,
                                          width: 104,
                                          height: 104,
                                        ),
                                        placeholder: Image.asset(
                                          AppImageAsset.avatar,
                                          fit: BoxFit.cover,
                                          width: 104,
                                          height: 104,
                                        ),
                                      )
                                    : Image.asset(
                                        AppImageAsset.avatar,
                                        fit: BoxFit.cover,
                                        width: 104,
                                        height: 104,
                                      ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD6B878),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isOwnProfile
                                    ? Icons.camera_alt_rounded
                                    : Icons.star_rounded,
                                color: const Color(0xFF16120D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 34,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFD6B878),
                          fontSize: 16,
                        ),
                      ),
                    ],
                    if (profileUsername != null) ...<Widget>[
                      const SizedBox(height: 6),
                      TextButton(
                        onPressed: _isOwnProfile ? showEditProfileDialog : null,
                        child: Text(
                          profileUsername,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    ] else if (_isOwnProfile) ...<Widget>[
                      const SizedBox(height: 10),
                    ],
                    if (bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
                        child: Text(
                          bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.76),
                            height: 1.45,
                          ),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        if (visibility.isNotEmpty)
                          _ProfileInfoChip(
                              icon: Icons.public_rounded, label: visibility),
                        if (postsCount > 0)
                          _ProfileInfoChip(
                            icon: Icons.dynamic_feed_outlined,
                            label: '$postsCount ${'posts_label'.tr}',
                          ),
                        if (_isOwnProfile && savedCount > 0)
                          _ProfileInfoChip(
                            icon: Icons.favorite_border_rounded,
                            label: '$savedCount ${'saved_label'.tr}',
                          ),
                        if (email.isNotEmpty)
                          _ProfileInfoChip(
                              icon: Icons.email_outlined, label: email),
                        if (phone.isNotEmpty)
                          _ProfileInfoChip(
                              icon: Icons.phone_outlined, label: phone),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_isOwnProfile) ...<Widget>[
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _toggleFollowUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowingUser
                              ? const Color(0xFF242321)
                              : const Color(0xFFD6B878),
                          foregroundColor: _isFollowingUser
                              ? const Color(0xFFE8D7B1)
                              : const Color(0xFF16120D),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: const BorderSide(color: Color(0xFF3B3125)),
                          ),
                        ),
                        child: Text(_isFollowingUser
                            ? 'following_label'.tr
                            : 'follow_label'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isFollowingUser ? _messageUser : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFE8D7B1),
                          side: const BorderSide(color: Color(0xFF3B3125)),
                          backgroundColor: const Color(0xFF242321),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text('message_label'.tr),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ProfileMetric(
                      value: '$followersCount',
                      label: 'followers_label'.tr,
                      onTap: () => _openSocialSheet('followers'),
                    ),
                  ),
                  Expanded(
                    child: _ProfileMetric(
                      value: '$followingCount',
                      label: 'following_label'.tr,
                      onTap: () => _openSocialSheet('following'),
                    ),
                  ),
                  Expanded(
                    child: _ProfileMetric(
                      value: '$postsCount',
                      label: 'posts_label'.tr,
                    ),
                  ),
                ],
              ),
              if (_isOwnProfile || hasSavedPerfumes)
                const SizedBox(height: 24),
              if (_isOwnProfile && hasSavedPerfumes) ...<Widget>[
                _SectionTitleRow(
                  title: 'saved_perfumes'.tr,
                  actionLabel: 'view_all'.tr,
                  onTap: () => Get.toNamed(AppRoutes.myfavroite),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 110,
                  child: Row(
                    children: _buildSavedPerfumeCards(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_isOwnProfile) ...<Widget>[
                _SectionTitleRow(
                  title: 'custom_perfumes'.tr,
                  actionLabel: 'Create Now',
                  onTap: () => Get.toNamed(AppRoutes.fragranceBuilder),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.fragranceBuilder),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242321),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF3B3125)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFFE8D29A),
                                Color(0xFFC39A5F),
                                Color(0xFF2A2116),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            color: Color(0xFF16120D),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                customPerfumes.isNotEmpty
                                    ? (customPerfumes.first['creation_name'] ??
                                            'Create your next custom perfume')
                                        .toString()
                                    : 'Create your next custom perfume',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                customPerfumes.isNotEmpty
                                    ? '${customPerfumes.length} ${'custom_perfumes'.tr}'
                                    : 'Blend notes, choose a bottle, and name your scent.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.66),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white30,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_isOwnProfile) ...<Widget>[
                Text(
                  'settings_label'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'myfont',
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 14),
                _SettingTile(
                  icon: Icons.edit_outlined,
                  title: 'edit_profile'.tr,
                  onTap: showEditProfileDialog,
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Retake Fragrance Quiz',
                  onTap: () => ensureFragranceFlowController().retakeQuiz(),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.tune_rounded,
                  title: 'Edit Preferences',
                  onTap: () =>
                      ensureFragranceFlowController().editPreferences(),
                ),
                const SizedBox(height: 12),
                _SettingTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'order_history'.tr,
                  onTap: () => Get.toNamed(AppRoutes.ordersarchive_page),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    final SettingsController controller =
                        Get.put(SettingsController());
                    controller.logout();
                  },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242321),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF3B3125)),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.logout_rounded, color: Color(0xFFD6B878)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Color(0xFFD6B878),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSavedPerfumeCards() {
    final List<Map<String, dynamic>> perfumes = savedPerfumes.take(3).toList();
    return List<Widget>.generate(
      perfumes.length,
      (int index) => Expanded(
        child: Padding(
          padding:
              EdgeInsets.only(right: index == perfumes.length - 1 ? 0 : 12),
          child: _MiniPerfumeCard(
            title: (perfumes[index]['items_name_en'] ??
                    perfumes[index]['creation_name'] ??
                    'Item #${perfumes[index]['items_id'] ?? index + 1}')
                .toString(),
            imagePath: (perfumes[index]['items_image'] ?? '').toString(),
          ),
        ),
      ),
    );
  }

  Widget _profileCircleButton({
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

class _ProfileInfoChip extends StatelessWidget {
  const _ProfileInfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF171512),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF31281E)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFFD6B878)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.value,
    required this.label,
    this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: <Widget>[
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFFD6B878),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    this.actionLabel,
    this.onTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'myfont',
              fontSize: 25,
            ),
          ),
        ),
        if (actionLabel != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: Color(0xFFD6B878),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniPerfumeCard extends StatelessWidget {
  const _MiniPerfumeCard({
    required this.title,
    this.imagePath = '',
  });

  final String title;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (imagePath.trim().isNotEmpty)
            FallbackNetworkImage(
              imageUrls: AppImageUrls.item(imagePath),
              label: title,
              fit: BoxFit.cover,
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFE8D29A),
                    Color(0xFFB48A4E),
                    Color(0xFF1E1A15),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_mall_outlined,
                color: Color(0xFF16120D),
                size: 32,
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withValues(alpha: 0),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomPerfumeCard extends StatelessWidget {
  const _CustomPerfumeCard({
    required this.title,
    required this.score,
  });

  final String title;
  final String score;

  @override
  Widget build(BuildContext context) {
    final String normalizedScore = score.trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFE8D29A),
                    Color(0xFFC39A5F),
                    Color(0xFF2A2116),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.science_outlined,
                color: Color(0xFF16120D),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'myfont',
                  ),
                ),
                const SizedBox(height: 6),
                if (normalizedScore.isNotEmpty)
                  Text(
                    normalizedScore,
                    style: const TextStyle(
                      color: Color(0xFFD6B878),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white30, size: 18),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF242321),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF3B3125)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: const Color(0xFFD6B878)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white30, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfileCard extends StatelessWidget {
  const _EmptyProfileCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.70),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
