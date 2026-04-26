import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/forgetpassword/resetpassword_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/alertexitapp.dart';
import 'package:tks/core/functions/validinput.dart';
import 'package:tks/view/widget/auth/auth_shell.dart';
import 'package:tks/view/widget/auth/customButtonauth.dart';
import 'package:tks/view/widget/auth/customtextformauth.dart';
import 'package:tks/view/widget/auth/logoauth.dart';

class resetpassword extends StatelessWidget {
  const resetpassword({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ResetPasswordControllerImp());
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return WillPopScope(
      onWillPop: alertExitApp,
      child: GetBuilder<ResetPasswordControllerImp>(
        builder: (controller) => HandlingDataView(
          statusRequest: controller.statusRequest,
          widget: AuthShell(
            title: t('كلمة مرور جديدة', 'New Password'),
            subtitle: t(
              'يرجى إدخال كلمة المرور الجديدة',
              'Please enter your new password',
            ),
            hero: const Logoauth(),
            caption: t(
              'عيّن كلمة مرور جديدة وآمنة',
              'Set a secure new password',
            ),
            form: Form(
              key: controller.formstate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AuthSectionTitle(
                    title: 'Create a new password',
                    subtitle:
                        'Choose a strong password to protect your saved perfume profile and purchase history.',
                  ),
                  const SizedBox(height: 18),
                  Customtextformauth(
                    hinttext: t('أدخل كلمة مرور جديدة', 'Enter a new password'),
                    labeltext: t('كلمة المرور', 'Password'),
                    iconData: Icons.lock_outline_rounded,
                    mycontroller: controller.password,
                    valid: (val) => validInput(val!, 8, 20, 'password'),
                    isNumber: false,
                    obscureText: true,
                  ),
                  Customtextformauth(
                    hinttext: t('أعد إدخال كلمة المرور', 'Re-enter password'),
                    labeltext: t('كلمة المرور', 'Password'),
                    iconData: Icons.lock_reset_outlined,
                    mycontroller: controller.repassword,
                    valid: (val) => validInput(val!, 8, 20, 'password'),
                    isNumber: false,
                    obscureText: true,
                  ),
                  const SizedBox(height: 6),
                  const AuthHelperCard(
                    icon: Icons.key_outlined,
                    title: 'Password tip',
                    subtitle:
                        'Use a password that is easy for you to remember and hard for others to guess.',
                  ),
                  const SizedBox(height: 16),
                  CustomButtomAuth(
                    text: t('حفظ', 'Save'),
                    onPressed: controller.goToSuccessResetPassword,
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
