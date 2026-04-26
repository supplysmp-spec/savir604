import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/localization/changelocal.dart';
import 'package:tks/core/services/services.dart';

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  late String selectedLangCode;
  final LocaleController controller = Get.find();
  final MyServices myServices = Get.find();

  final List<Map<String, String>> languages = const [
    {
      'code': 'ar',
      'name': 'العربية',
      'subtitle': 'واجهة عربية كاملة واتجاه مناسب للقراءة',
      'flag': 'assets/images/egypt.png',
    },
    {
      'code': 'en',
      'name': 'English',
      'subtitle': 'A clean English interface for browsing the store',
      'flag': 'assets/images/amrica.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedLangCode = controller.language.languageCode;
  }

  void _changeLanguage(String code) {
    setState(() {
      selectedLangCode = code;
    });
    controller.changeLang(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = selectedLangCode == 'ar';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? const Color(0xFF151515) : const Color(0xFFFFFEFB),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1B1B1B),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -26,
                        right: isArabic ? null : -8,
                        left: isArabic ? -8 : null,
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              isArabic ? 'اختر اللغة' : 'Choose language',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isArabic ? 'لغة التطبيق' : 'App language',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isArabic
                                ? 'حدد اللغة التي تفضل استخدامها داخل التطبيق.'
                                : 'Select the language you want to use across the app.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    itemCount: languages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = selectedLangCode == lang['code'];

                      return InkWell(
                        onTap: () => _changeLanguage(lang['code']!),
                        borderRadius: BorderRadius.circular(26),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : theme.dividerColor.withValues(alpha: 0.55),
                              width: isSelected ? 1.6 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF222222)
                                      : const Color(0xFFF4F4EE),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Image.asset(
                                  lang['flag']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang['name']!,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      lang['subtitle']!,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  color: isSelected ? colors.primary : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? colors.primary : theme.dividerColor,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        color: colors.onPrimary,
                                        size: 18,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await myServices.sharedPreferences.setString('step', '1');
                      Get.offAllNamed(AppRoutes.login);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(isArabic ? 'متابعة' : 'Continue'),
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
