import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/forgetpassword/forget_controler.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/customButtonauth.dart';
import 'package:tks/view/widget/auth/customtextformauth.dart';
import 'package:tks/view/widget/auth/logoauth.dart';

class Forgetpassword extends StatelessWidget {
  const Forgetpassword({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ForgetPasswordControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<ForgetPasswordControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('تحقق من بريدك الإلكتروني', 'Check your email'),
            subtitle: t(
              'يرجى إدخال بريدك الإلكتروني لاستلام رمز التحقق',
              'Please enter your email to receive the verification code',
            ),
            hero: const Logoauth(),
            caption: t(
              'استعد حسابك بأمان',
              'Recover your fragrance account securely',
            ),
            form: Form(
              key: controller.formstate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AuthSectionTitle(
                    title: 'Reset access',
                    subtitle:
                        'Enter the email linked to your account and we will send a verification code to continue.',
                  ),
                  const SizedBox(height: 18),
                  Customtextformauth(
                    hinttext: t('أدخل بريدك الإلكتروني', 'Enter your email'),
                    labeltext: t('البريد الإلكتروني', 'Email'),
                    iconData: Icons.email_outlined,
                    mycontroller: controller.email,
                    valid: (val) => null,
                    isNumber: false,
                  ),
                  const SizedBox(height: 6),
                  const AuthHelperCard(
                    icon: Icons.mark_email_read_outlined,
                    title: 'Secure recovery',
                    subtitle:
                        'Use the same email you registered with to avoid interruptions during the reset flow.',
                  ),
                  const SizedBox(height: 16),
                  CustomButtomAuth(
                    text: t('تحقق', 'Check'),
                    onPressed: controller.checkemail,
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
