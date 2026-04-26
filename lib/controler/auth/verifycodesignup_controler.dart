import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/handingdatacontroller.dart';
import 'package:tks/data/datasource/remote/auth/verfiycodesignup.dart';

abstract class VerifyCodeSignUpController extends GetxController {
  checkCode();
  goToSuccessSignUp(String verfiyCodeSignUp);
}

class VerifyCodeSignUpControllerImp extends VerifyCodeSignUpController {
  final VerfiyCodeSignUpData verfiyCodeSignUpData =
      VerfiyCodeSignUpData(Get.find());

  String? email;
  StatusRequest statusRequest = StatusRequest.none;

  bool get _isArabic => Get.locale?.languageCode == 'ar';
  String _t(String ar, String en) => _isArabic ? ar : en;

  @override
  checkCode() {}

  @override
  goToSuccessSignUp(verfiyCodeSignUp) async {
    statusRequest = StatusRequest.loading;
    update();
    final response =
        await verfiyCodeSignUpData.postdata(email!, verfiyCodeSignUp);
    statusRequest = handlingData(response);
    if (StatusRequest.success == statusRequest) {
      if (response['status'] == "success") {
        Get.offNamed(AppRoutes.successSignUp);
      } else {
        Get.defaultDialog(
          title: _t('تحذير', 'Warning'),
          middleText: _t('رمز التحقق غير صحيح', 'Verify Code Not Correct'),
        );
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }

  @override
  void onInit() {
    email = Get.arguments['email'];
    super.onInit();
  }

  void reSend() {
    verfiyCodeSignUpData.resendData(email!);
  }
}
