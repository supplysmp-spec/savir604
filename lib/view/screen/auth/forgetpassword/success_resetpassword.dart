import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/auth/successresetpassword_controler.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';

class SuccessResetPassword extends StatelessWidget {
  const SuccessResetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SuccessResetPasswordControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return AuthSuccessScreen(
      icon: Icons.verified_user_outlined,
      title: t('تم تحديث كلمة المرور', 'Password updated'),
      subtitle: t(
        'أصبح حسابك آمنًا مرة أخرى. سجّل الدخول بكلمة المرور الجديدة للمتابعة.',
        'Your account is secure again. Sign in with your new password to continue your fragrance journey.',
      ),
      buttonText: t('الانتقال إلى تسجيل الدخول', 'Go to Login'),
      onPressed: controller.goToPageLogin,
    );
  }
}
