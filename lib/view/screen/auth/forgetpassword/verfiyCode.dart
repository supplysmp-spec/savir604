import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:tks/controler/forgetpassword/verifycode_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/logoauth.dart';

class Verfiycode extends StatelessWidget {
  const Verfiycode({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VerifyCodeControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<VerifyCodeControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('تحقق من البريد الإلكتروني', 'Check Email'),
            subtitle: t(
              'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني.',
              'Enter the verification code sent to your email.',
            ),
            hero: const Logoauth(),
            caption: t(
              'تأكيد آمن لاستعادة كلمة المرور',
              'Secure password recovery verification',
            ),
            form: _OtpCard(
              title: t('تأكيد بريدك الإلكتروني', 'Verify your email'),
              subtitle: t(
                'استخدم رمز التحقق المكون من 5 أرقام الذي أرسلناه للمتابعة في إعادة تعيين كلمة المرور بأمان.',
                'Use the 5-digit code we sent to continue resetting your password securely.',
              ),
              helperTitle: t('التحقق من الهوية', 'Identity check'),
              helperSubtitle: t(
                'نتحقق من هذه الخطوة قبل السماح بأي تغيير لكلمة المرور في حسابك.',
                'We verify this step before allowing any password changes on your account.',
              ),
              onSubmit: controller.goToResetPassword,
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.title,
    required this.subtitle,
    required this.helperTitle,
    required this.helperSubtitle,
    required this.onSubmit,
  });

  final String title;
  final String subtitle;
  final String helperTitle;
  final String helperSubtitle;
  final void Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AuthSectionTitle(title: title, subtitle: subtitle),
        const SizedBox(height: 18),
        AuthHelperCard(
          icon: Icons.lock_person_outlined,
          title: helperTitle,
          subtitle: helperSubtitle,
        ),
        const SizedBox(height: 24),
        Directionality(
          textDirection: TextDirection.ltr,
          child: OtpTextField(
            numberOfFields: 5,
            fieldWidth: 48,
            fieldHeight: 62,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            borderRadius: BorderRadius.circular(16),
            borderColor: const Color(0xFFD6B878),
            focusedBorderColor: const Color(0xFFD6B878),
            enabledBorderColor: const Color(0xFFD8C8AF),
            showFieldAsBox: true,
            fillColor: const Color(0xFFFFFCF7),
            filled: true,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            contentPadding: EdgeInsets.zero,
            textStyle: const TextStyle(
              color: Color(0xFF15120D),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
            onCodeChanged: (_) {},
            onSubmit: onSubmit,
          ),
        ),
      ],
    );
  }
}
