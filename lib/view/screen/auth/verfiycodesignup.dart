import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:tks/controler/auth/verifycodesignup_controler.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/logoauth.dart';

class Verfiycodesignup extends StatelessWidget {
  const Verfiycodesignup({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(VerifyCodeSignUpControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<VerifyCodeSignUpControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('رمز التحقق', 'Verify Code'),
            subtitle: t(
              'أكد حسابك باستخدام الرمز المرسل إلى بريدك الإلكتروني.',
              'Confirm your account using the code sent to your email.',
            ),
            hero: const Logoauth(),
            caption: t(
              'خطوة واحدة تفصلك عن حسابك',
              'One step away from your fragrance profile',
            ),
            form: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AuthSectionTitle(
                  title: t('تأكيد الحساب', 'Account verification'),
                  subtitle: t(
                    'أدخل رمز التحقق المكون من 5 أرقام الذي أرسلناه إلى بريدك الإلكتروني لتفعيل حسابك.',
                    'Enter the 5-digit code we sent to your email to activate your Precious Fragrance account.',
                  ),
                ),
                const SizedBox(height: 18),
                AuthHelperCard(
                  icon: Icons.verified_user_outlined,
                  title: t('يلزم تأكيد البريد الإلكتروني', 'Email confirmation required'),
                  subtitle: t(
                    'هذه الخطوة السريعة تحمي تفضيلاتك المحفوظة وسجل التوصيات.',
                    'This quick step protects your saved preferences and recommendation history.',
                  ),
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
                    onSubmit: controller.goToSuccessSignUp,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: controller.reSend,
                    child: Text(
                      t('إعادة إرسال الرمز', 'Resend code'),
                      style: const TextStyle(
                        color: Color(0xFF8C6A2F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
