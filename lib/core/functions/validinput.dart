import 'package:get/get.dart';

String? validInput(String val, int min, int max, String type) {
  final bool isArabic = Get.locale?.languageCode == 'ar';

  String t(String ar, String en) => isArabic ? ar : en;

  String typeName() {
    switch (type) {
      case 'username':
        return t('اسم المستخدم', 'Username');
      case 'email':
        return t('البريد الإلكتروني', 'Email');
      case 'phone':
        return t('رقم الهاتف', 'Phone number');
      case 'password':
        return t('كلمة المرور', 'Password');
      default:
        return type;
    }
  }

  if (val.isEmpty) {
    return t('لا يمكن أن يكون الحقل فارغًا', "Can't be empty");
  }

  if (val.length < min || val.length > max) {
    return t(
      '${typeName()} يجب أن يكون بين $min و $max حرفًا',
      '${typeName()} must be between $min and $max characters',
    );
  }

  if (type == 'username') {
    final validNameRegex =
        RegExp(r'^[\p{L}\p{N}]+(?: [\p{L}\p{N}]+)*$', unicode: true);

    if (!validNameRegex.hasMatch(val)) {
      return t(
        'اسم المستخدم غير صالح. استخدم حروفًا أو أرقامًا ويمكنك إضافة مسافة واحدة بين الكلمات',
        'Username is invalid. Use letters or numbers, with at most one space between words',
      );
    }
  }

  if (type == 'email' && !GetUtils.isEmail(val)) {
    return t('البريد الإلكتروني غير صالح', 'Email is not valid');
  }

  if (type == 'phone' && !GetUtils.isPhoneNumber(val)) {
    return t('رقم الهاتف غير صالح', 'Phone number is not valid');
  }

  return null;
}
