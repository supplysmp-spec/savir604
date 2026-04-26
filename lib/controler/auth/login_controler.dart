// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/core/functions/save_token.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';
import 'package:tks/data/datasource/remote/auth/login.dart';
import 'package:tks/data/datasource/remote/auth/social_login.dart';

abstract class LoginController extends GetxController {
  Future<void> login();
  void goToSignUp();
  void goToForgetPassword();
  Future<void> loginWithGoogle();
}

class LoginControllerImp extends LoginController {
  LoginData loginData = LoginData(Get.find());
  SocialLoginData socialLoginData = SocialLoginData(Get.find());
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  late TextEditingController email;
  late TextEditingController password;

  bool isshowpassword = true;
  bool rememberMe = false;

  MyServices myServices = Get.find();

  StatusRequest statusRequest = StatusRequest.none;
  bool get _isArabic => Get.locale?.languageCode == 'ar';
  String _t(String ar, String en) => _isArabic ? ar : en;

  void showPassword() {
    isshowpassword = !isshowpassword;
    update();
  }

  void toggleRemember(bool val) {
    rememberMe = val;
    update();
  }

  @override
  Future<void> login() async {
    if (formstate.currentState!.validate()) {
      statusRequest = StatusRequest.loading;
      update();

      final response = await loginData.postdata(email.text, password.text);
      print("=============================== Controller $response ");
      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success") {
          await _persistSessionAndGoHome(response['data']);
        } else {
          _showLoginErrorDialog(
            title: _t("تحذير", "Warning"),
            message: _t(
              "البريد الإلكتروني أو كلمة المرور غير صحيحة.\nيرجى المحاولة مرة أخرى.",
              "Email or Password not correct.\nPlease try again.",
            ),
          );
          statusRequest = StatusRequest.failure;
        }
      }

      update();
    }
  }

  @override
  Future<void> loginWithGoogle() async {
    await _loginWithProvider(_SocialProvider.google);
  }

  Future<void> _loginWithProvider(_SocialProvider provider) async {
    statusRequest = StatusRequest.loading;
    update();

    try {
      final socialUser = await _authenticateWithProvider(provider);
      if (socialUser == null) {
        statusRequest = StatusRequest.none;
        update();
        return;
      }

      if ((socialUser.email ?? "").trim().isEmpty) {
        statusRequest = StatusRequest.failure;
        update();
        Get.snackbar(
          _t("البريد الإلكتروني مفقود", "Missing email"),
          _t(
            "الحساب المحدد لم يوفّر عنوان بريد إلكتروني.",
            "The selected account did not provide an email address.",
          ),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final response = await socialLoginData.postData(
        provider: provider.name,
        socialId: socialUser.uid,
        email: socialUser.email!,
        name: (socialUser.displayName ?? socialUser.email!).trim(),
        photoUrl: socialUser.photoURL,
      );

      statusRequest = handlingData(response);

      if (StatusRequest.success == statusRequest) {
        if (response['status'] == "success" && response['data'] is Map) {
          await _persistSessionAndGoHome(response['data'] as Map);
        } else {
          statusRequest = StatusRequest.failure;
          _showLoginErrorDialog(
            title: _t("فشل تسجيل الدخول الاجتماعي", "Social login failed"),
            message: _t(
              "تعذر ربط هذا الحساب الاجتماعي من الخادم.\nيرجى المحاولة مرة أخرى.",
              "Unable to link this social account from server.\nPlease try again.",
            ),
          );
        }
      } else {
        Get.snackbar(
          _t("مشكلة في الاتصال", "Connection issue"),
          _t(
            "تعذر إكمال تسجيل الدخول الاجتماعي الآن.",
            "Unable to complete social login right now.",
          ),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on FirebaseAuthException catch (e, st) {
      print("Google Auth FirebaseAuthException code: ${e.code}");
      print("Google Auth FirebaseAuthException message: ${e.message}");
      print("Google Auth FirebaseAuthException details: $e");
      print("Google Auth FirebaseAuthException stack: $st");
      statusRequest = StatusRequest.failure;
      update();
      Get.snackbar(
        _t("فشل تسجيل الدخول عبر Google", "Google sign-in failed"),
        "${e.code}: ${e.message ?? _t('خطأ غير معروف من FirebaseAuth', 'Unknown FirebaseAuth error')}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, st) {
      print("Google Auth unknown error: $e");
      print("Google Auth unknown stack: $st");
      statusRequest = StatusRequest.failure;
      update();
      Get.snackbar(
        _t("خطأ في تسجيل الدخول الاجتماعي", "Social login error"),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    update();
  }

  Future<User?> _authenticateWithProvider(_SocialProvider provider) async {
    switch (provider) {
      case _SocialProvider.google:
        return _signInWithGoogle();
    }
  }

  Future<User?> _signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      final credential = await _firebaseAuth.signInWithPopup(googleProvider);
      return credential.user;
    }

    final googleProvider = GoogleAuthProvider();
    googleProvider.addScope('email');
    final userCredential = await _firebaseAuth.signInWithProvider(googleProvider);
    return userCredential.user;
  }

  Future<void> _persistSessionAndGoHome(Map userData) async {
    final dynamic idRaw = userData['users_id'] ?? userData['id'];
    final int? userId = idRaw is int ? idRaw : int.tryParse('$idRaw');
    if (userId == null) {
      throw Exception("Server did not return a valid user id.");
    }

    await myServices.sharedPreferences.setInt("id", userId);
    await myServices.sharedPreferences
        .setString("username", "${userData['users_name'] ?? userData['username'] ?? ''}");
    await myServices.sharedPreferences
        .setString("email", "${userData['users_email'] ?? userData['email'] ?? ''}");
    await myServices.sharedPreferences
        .setString("phone", "${userData['users_phone'] ?? userData['phone'] ?? ''}");
    await myServices.sharedPreferences.setString("step", "2");

    await saveUserToken(userId);
    await ensureFragranceFlowController().routeAfterLogin();
  }

  void _showLoginErrorDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 68, 82),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed(AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 48, 56),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void goToSignUp() {
    Get.offNamed(AppRoutes.SignUp);
  }

  @override
  void goToForgetPassword() {
    Get.toNamed(AppRoutes.forgetPassword);
  }

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}

enum _SocialProvider { google }
