import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<bool> checkInternet() async {
  if (kIsWeb) {
    // افتراض أن الإنترنت متاح دائمًا على الويب
    return true;
  }
  try {
    var result = await InternetAddress.lookup("www.google.com");
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
