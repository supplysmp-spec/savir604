import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/auth/successsignup_controler.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';

class SuccessSignUp extends StatelessWidget {
  const SuccessSignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SuccessSignUpControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return AuthSuccessScreen(
      icon: Icons.check_circle_outline_rounded,
      title: t('حسابك أصبح جاهزًا', 'Your account is ready'),
      subtitle: t(
        'يمكنك الآن تسجيل الدخول وبدء استكشاف تجربتك المخصصة.',
        'You can now sign in and start exploring your personalized Precious Fragrance experience.',
      ),
      buttonText: t('الانتقال إلى تسجيل الدخول', 'Go to Login'),
      onPressed: controller.goToPageLogin,
    );
  }
}
