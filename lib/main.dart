// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/bindings/intialbindings.dart';
import 'package:tks/controler/them/theme_controller.dart';
import 'package:tks/core/localization/changelocal.dart';
import 'package:tks/core/services/background_music_service.dart';
import 'package:tks/core/localization/transaltion.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/core/theme/app_theme.dart';
import 'package:tks/firebase/firebase_notifications.dart';
import 'package:tks/firebase_options.dart';
import 'package:tks/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initialServices();

  if (!kIsWeb) {
    await FirebaseMessagingService().initFirebaseMessaging();
  }

  await Get.putAsync(() => BackgroundMusicService().init());
  runApp(const TksApp());
}

class TksApp extends StatelessWidget {
  const TksApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(LocaleController());
    Get.put(ThemeController(Get.find()));

    return GetMaterialApp(
      translations: MyTranslation(),
      debugShowCheckedModeBanner: false,
      locale: localeController.language,
      darkTheme: AppTheme.darkTheme(),
      theme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      initialBinding: InitialBindings(),
      getPages: routes,
    );
  }
}
