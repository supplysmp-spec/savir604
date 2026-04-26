import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/auth/signup_controler.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/core/functions/validinput.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/customButtonauth.dart';
import 'package:tks/view/widget/auth/customtextformauth.dart';
import 'package:tks/view/widget/auth/logoauth.dart';

class signUp extends StatelessWidget {
  const signUp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SignUpControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<SignUpControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('مرحبًا بك في صفحة التسجيل', 'Welcome to the registration page'),
            subtitle: t(
              'في هذه الصفحة يمكنك إنشاء حساب عن طريق تعبئة الحقول التالية',
              'On this page, you can create an account by filling in the fields below',
            ),
            hero: const Logoauth(),
            caption: t(
              'ابدأ رحلتك الخاصة مع العطور',
              'Create your signature fragrance journey',
            ),
            form: Form(
              key: controller.formstate,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AuthSectionTitle(
                    title: 'Create your account',
                    subtitle:
                        'Set up your profile to unlock personalized perfume matches, saved favorites, and premium gifting tools.',
                  ),
                  const SizedBox(height: 18),
                  Customtextformauth(
                    hinttext: t('أدخل اسم المستخدم', 'Enter username'),
                    labeltext: t('اسم المستخدم', 'Username'),
                    iconData: Icons.person_outline,
                    mycontroller: controller.username,
                    valid: (val) => validInput(val!, 3, 20, 'username'),
                    isNumber: false,
                  ),
                  Customtextformauth(
                    hinttext: t('أدخل بريدك الإلكتروني', 'Enter your email'),
                    labeltext: t('البريد الإلكتروني', 'Email'),
                    iconData: Icons.alternate_email_rounded,
                    mycontroller: controller.email,
                    valid: (val) => validInput(val!, 8, 100, 'email'),
                    isNumber: false,
                  ),
                  Customtextformauth(
                    hinttext: t('أدخل رقم الهاتف', 'Enter phone number'),
                    labeltext: t('رقم الهاتف', 'Phone Number'),
                    iconData: Icons.phone_outlined,
                    mycontroller: controller.phone,
                    valid: (val) => validInput(val!, 10, 18, 'phone'),
                    isNumber: true,
                  ),
                  Customtextformauth(
                    hinttext: t('أدخل كلمة المرور', 'Enter your password'),
                    labeltext: t('كلمة المرور', 'Password'),
                    iconData: controller.isshowpassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    mycontroller: controller.password,
                    valid: (val) => validInput(val!, 8, 20, 'password'),
                    isNumber: false,
                    obscureText: controller.isshowpassword,
                    onTapIcon: controller.showPassword,
                  ),
                  const SizedBox(height: 6),
                  const AuthHelperCard(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Why sign up?',
                    subtitle:
                        'We use your profile to personalize notes, home feed, and future builder suggestions.',
                  ),
                  const SizedBox(height: 16),
                  CustomButtomAuth(
                    text: t('إنشاء حساب', 'Create Account'),
                    onPressed: controller.signUp,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        t('لديك حساب بالفعل؟', 'Already have an account?'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: controller.goToSignIn,
                        child: Text(
                          t('تسجيل الدخول', 'Sign in'),
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
