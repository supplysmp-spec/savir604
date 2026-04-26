import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:tks/controler/home/homescreen_controller.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/view/screen/support.dart';
import 'package:tks/view/widget/home/custombottomappbarhome.dart';
import 'package:tks/view/widget/home/first_launch_welcome_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _welcomeDialogsSeenKey = 'welcome_dialogs_seen';

  @override
  void initState() {
    super.initState();
    Get.put(HomeScreenControllerImp());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialogsIfNeeded();
    });
  }

  Future<void> _showWelcomeDialogsIfNeeded() async {
    final MyServices services = Get.find<MyServices>();
    final bool hasSeen = services.sharedPreferences.getBool(_welcomeDialogsSeenKey) ?? false;
    if (hasSeen || !mounted) return;

    await Get.dialog(
      FirstLaunchWelcomeDialog(
        isArabic: Get.locale?.languageCode == 'ar',
        onFinish: () async {
          await services.sharedPreferences.setBool(_welcomeDialogsSeenKey, true);
          if (Get.isDialogOpen == true) {
            Get.back();
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return GetBuilder<HomeScreenControllerImp>(
      builder: (HomeScreenControllerImp controller) {
        return Scaffold(
          extendBody: true,
          backgroundColor: palette.scaffoldBackground,
          floatingActionButton: controller.currentpage == 0
              ? _SupportBotButton(
                  enabled: controller.userId > 0,
                  onTap: () => Get.to(
                    () => SupportHome(userId: controller.userId),
                  ),
                )
              : null,
          bottomNavigationBar: const CustomBottomAppBarHome(),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.screenGradient,
              ),
            ),
            child: controller.listPage.elementAt(controller.currentpage),
          ),
          resizeToAvoidBottomInset: false,
        );
      },
    );
  }
}

class _SupportBotButton extends StatelessWidget {
  const _SupportBotButton({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Lottie.asset(
                      'assets/json/animation.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212).withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Support',
                      style: TextStyle(
                        color: Color(0xFFE9D5AC),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
