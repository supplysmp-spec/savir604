import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/auth/login_controler.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/core/functions/validinput.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/customButtonauth.dart';
import 'package:tks/view/widget/auth/customtextformauth.dart';
import 'package:tks/view/widget/auth/logoauth.dart';
import 'package:tks/view/widget/auth/social_login_buttons.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<LoginControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('مرحبًا بعودتك', 'Welcome Back'),
            subtitle: t(
              'يمكنك تسجيل الدخول باستخدام بريدك الإلكتروني وكلمة المرور',
              'You can log in using your email and password',
            ),
            hero: const Logoauth(),
            caption: t(
              'وصول فاخر مخصص إلى عالم العطور',
              'Personalized luxury fragrance access',
            ),
            form: Form(
              key: controller.formstate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AuthSectionTitle(
                    title: 'Welcome back',
                    subtitle:
                        'Sign in to revisit your fragrance profile, wishlist, and tailored scent recommendations.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E6CB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0C28C)),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.touch_app_outlined, color: Color(0xFF8C6A2F), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your sign-in fields are right below.',
                            style: TextStyle(
                              color: Color(0xFF73582A),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Customtextformauth(
                    hinttext: t('أدخل بريدك الإلكتروني', 'Enter your email'),
                    labeltext: t('البريد الإلكتروني', 'Email'),
                    iconData: Icons.email_outlined,
                    mycontroller: controller.email,
                    valid: (val) => validInput(val!, 5, 100, 'email'),
                    isNumber: false,
                  ),
                  Customtextformauth(
                    hinttext: t('أدخل كلمة المرور', 'Enter your password'),
                    labeltext: t('كلمة المرور', 'Password'),
                    iconData: controller.isshowpassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    mycontroller: controller.password,
                    obscureText: controller.isshowpassword,
                    onTapIcon: controller.showPassword,
                    valid: (val) => validInput(val!, 3, 30, 'password'),
                    isNumber: false,
                  ),
                  const SizedBox(height: 4),
                  const AuthHelperCard(
                    icon: Icons.shield_outlined,
                    title: 'Private account access',
                    subtitle:
                        'Your saved scents, gift selections, and recommendations stay synced across sessions.',
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: controller.goToForgetPassword,
                      child: Text(
                        t('هل نسيت كلمة المرور؟', 'Forgot your password?'),
                        style: const TextStyle(
                          color: Color(0xFF8C6A2F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  CustomButtomAuth(
                    text: t('تسجيل الدخول', 'Login'),
                    onPressed: controller.login,
                  ),
                  const SizedBox(height: 14),
                  SocialLoginButtons(
                    onGoogleTap: controller.loginWithGoogle,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(t('ليس لديك حساب؟', "Don't have an account?")),
                      TextButton(
                        onPressed: controller.goToSignUp,
                        child: Text(
                          t('أنشئ حسابًا الآن', 'Create one now'),
                          style: const TextStyle(
                            color: Color(0xFF8C6A2F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
