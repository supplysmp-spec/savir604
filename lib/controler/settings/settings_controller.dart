// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/services/services.dart';
import 'package:get/get.dart';
import 'package:tks/linkapi/linkapi.dart';

class SettingsController extends GetxController {
  MyServices myServices = Get.find();

  logout() {
    int userid = myServices.sharedPreferences.getInt("id")!;
    // تم إزالة FirebaseMessaging
    myServices.sharedPreferences.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  // profile properties
  Map<String, dynamic>? userData;
  bool isLoadingProfile = false;

  String get displayName {
    final data = userData ?? <String, dynamic>{};
    return (data['display_name'] ??
            data['users_name'] ??
            myServices.sharedPreferences.getString('display_name') ??
            myServices.sharedPreferences.getString('users_name') ??
            myServices.sharedPreferences.getString('username') ??
            'User')
        .toString();
  }

  String get username {
    final data = userData ?? <String, dynamic>{};
    final raw = (data['username'] ??
            myServices.sharedPreferences.getString('username') ??
            '')
        .toString()
        .trim();
    if (raw.isEmpty) {
      return 'profile_default_user'.tr;
    }
    return raw.startsWith('@') ? raw : '@$raw';
  }

  String get email {
    final data = userData ?? <String, dynamic>{};
    return (data['users_email'] ??
            myServices.sharedPreferences.getString('email') ??
            '')
        .toString();
  }

  Future<void> getProfile() async {
    final id = myServices.sharedPreferences.getInt('id');
    if (id == null) return;
    isLoadingProfile = true;
    update();

    final url = Uri.parse(AppLink.userProfileGet);
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': id.toString(),
          'viewer_id': id.toString(),
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final root = decoded is Map<String, dynamic>
            ? decoded
            : Map<String, dynamic>.from(decoded);
        final nested = root['data'];
        userData = nested is Map<String, dynamic>
            ? Map<String, dynamic>.from(nested)
            : root;

        final imageName = (userData?['users_image'] ?? '').toString().trim();
        final usersName = (userData?['users_name'] ?? '').toString().trim();
        final display = (userData?['display_name'] ?? '').toString().trim();
        final user = (userData?['username'] ?? '').toString().trim();

        if (imageName.isNotEmpty) {
          await myServices.sharedPreferences.setString('users_image', imageName);
        }
        final avatarUrl = AppLink.normalizeUrl(
          (userData?['profile_image_url'] ?? userData?['avatar_url'] ?? '')
            .toString()
            .trim(),
        );
        if (avatarUrl.isNotEmpty) {
          await myServices.sharedPreferences.setString('avatar_url', avatarUrl);
        }
        if (usersName.isNotEmpty) {
          await myServices.sharedPreferences.setString('users_name', usersName);
        }
        if (display.isNotEmpty) {
          await myServices.sharedPreferences.setString('display_name', display);
        }
        if (user.isNotEmpty) {
          await myServices.sharedPreferences.setString('username', user);
        }
      }
    } catch (e) {
      // ignore network errors for now
      print('getProfile error: $e');
    }

    isLoadingProfile = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }
}
