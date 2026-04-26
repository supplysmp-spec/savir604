import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/settings/settings_controller.dart';
import 'package:tks/core/constant/imsgesassets.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/localization/changelocal.dart';
import 'package:tks/core/services/background_music_service.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/view/screen/profile_page.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.put(SettingsController());
    final localeController = Get.find<LocaleController>();
    final myServices = Get.find<MyServices>();
    final musicService = Get.find<BackgroundMusicService>();
    final theme = Theme.of(context);
    final palette = _SettingsPalette.fromTheme(theme);
    final bool isArabic = localeController.language.languageCode == 'ar';

    String t(String ar, String en) => isArabic ? ar : en;

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.backgroundGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 132),
            children: <Widget>[
              GetBuilder<SettingsController>(
                builder: (settings) {
                  final ImageProvider imageProvider = _profileImage(settings);
                  final String title = settings.displayName;
                  final String handle = settings.username;
                  final String contact = settings.email;
                  final int userId =
                      myServices.sharedPreferences.getInt('id') ?? 0;

                  return AppTopBanner(
                    title: t('الإعدادات', 'Settings'),
                    subtitle: t(
                      'خصص تجربتك، وراجع طلباتك، وحافظ على جاهزية ملفك الشخصي لكل اكتشاف جديد.',
                      'Tune your experience, revisit your orders, and keep your profile ready for every new discovery.',
                    ),
                    leadingIcon: Icons.arrow_back_rounded,
                    onLeadingTap: Get.back,
                    trailingIcon: Icons.info_outline_rounded,
                    onTrailingTap: () => Get.toNamed(AppRoutes.aboutus),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            if (userId > 0) {
                              Get.to(() => ProfilePage(userId: userId));
                            }
                          },
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: palette.heroCardColor,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: palette.heroCardBorder),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: palette.accent.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: imageProvider,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          color: palette.primaryText,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        handle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: palette.secondaryText,
                                        ),
                                      ),
                                      if (contact.isNotEmpty) ...<Widget>[
                                        const SizedBox(height: 4),
                                        Text(
                                          contact,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: palette.tertiaryText,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: palette.tertiaryText,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AppTopBannerMetric(
                                value: userId > 0 ? '$userId' : '--',
                                label: t('رقم العضوية', 'Member ID'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTopBannerMetric(
                                value: contact.isEmpty
                                    ? t('الملف الشخصي', 'Profile')
                                    : t('جاهز', 'Ready'),
                                label: contact.isEmpty
                                    ? t('أضف المزيد من المعلومات', 'Add more info')
                                    : t('تمت مزامنة الحساب', 'Account synced'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: t('التحكم السريع', 'Quick Controls'),
                palette: palette,
                child: Column(
                  children: <Widget>[
                    _InfoTile(
                      palette: palette,
                      icon: Icons.dark_mode_outlined,
                      title: t('الوضع الداكن', 'Dark theme'),
                      subtitle: t(
                        'يتم تطبيق الوضع الداكن على كامل التطبيق',
                        'Dark mode is applied across the app',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => _GlassSwitchTile(
                        palette: palette,
                        icon: Icons.music_note_outlined,
                        title: t('الموسيقى الخلفية', 'Ambient music'),
                        subtitle: t(
                          'تشغيل أو إيقاف موسيقى الخلفية داخل التطبيق',
                          'Turn in-app background music on or off',
                        ),
                        value: musicService.isEnabled.value,
                        onChanged: musicService.toggle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: t('اللغة', 'Language'),
                palette: palette,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _LanguageTile(
                        palette: palette,
                        title: t('العربية', 'Arabic'),
                        subtitle: t('استخدم اللغة العربية', 'Use Arabic language'),
                        assetPath: 'assets/images/egypt-flag-gif.gif',
                        onTap: () => localeController.changeLang('ar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LanguageTile(
                        palette: palette,
                        title: t('الإنجليزية', 'English'),
                        subtitle:
                            t('استخدم اللغة الإنجليزية', 'Use English language'),
                        assetPath: 'assets/images/am.gif',
                        onTap: () => localeController.changeLang('en'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: t('استكشف', 'Explore'),
                palette: palette,
                child: Column(
                  children: <Widget>[
                    _LuxuryActionTile(
                      palette: palette,
                      title: t('الملف الشخصي', 'Profile'),
                      subtitle: t(
                        'أدر صورتك ونبذتك ومعلوماتك العامة',
                        'Manage your image, bio, and public details',
                      ),
                      icon: Icons.person_outline_rounded,
                      onTap: () {
                        final int? userId =
                            myServices.sharedPreferences.getInt('id');
                        if (userId != null) {
                          Get.to(() => ProfilePage(userId: userId));
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LuxuryActionTile(
                      palette: palette,
                      title: t('العنوان', 'Address'),
                      subtitle: t(
                        'إدارة تفاصيل التوصيل',
                        'Manage delivery details',
                      ),
                      icon: Icons.location_on_outlined,
                      onTap: () => Get.toNamed(AppRoutes.addressview),
                    ),
                    const SizedBox(height: 12),
                    _LuxuryActionTile(
                      palette: palette,
                      title: t('أرشيف الطلبات', 'Orders archive'),
                      subtitle: t(
                        'عرض الطلبات السابقة',
                        'See previous orders',
                      ),
                      icon: Icons.archive_outlined,
                      onTap: () => Get.toNamed(AppRoutes.ordersarchive_page),
                    ),
                    const SizedBox(height: 12),
                    _LuxuryActionTile(
                      palette: palette,
                      title: t('حول التطبيق', 'About app'),
                      subtitle: t(
                        'اعرف المزيد عن سافير',
                        'Learn more about Savir',
                      ),
                      icon: Icons.help_outline_rounded,
                      onTap: () => Get.toNamed(AppRoutes.aboutus),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: t('إجراءات الحساب', 'Account Actions'),
                palette: palette,
                child: Column(
                  children: <Widget>[
                    GetBuilder<SettingsController>(
                      builder: (settings) => Row(
                        children: <Widget>[
                          Expanded(
                            child: _MiniActionButton(
                              palette: palette,
                              label: t('فتح الملف الشخصي', 'Open Profile'),
                              icon: Icons.person_outline_rounded,
                              filled: false,
                              onTap: () {
                                final int? userId =
                                    myServices.sharedPreferences.getInt('id');
                                if (userId != null) {
                                  Get.to(() => ProfilePage(userId: userId));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniActionButton(
                              palette: palette,
                              label: settings.isLoadingProfile
                                  ? t('جارٍ التحديث...', 'Refreshing...')
                                  : t('تحديث', 'Refresh'),
                              icon: Icons.refresh_rounded,
                              filled: true,
                              onTap: settings.isLoadingProfile
                                  ? null
                                  : settings.getProfile,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _logoutTile(context, settingsController, palette),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  t('v603.1 • © سافير تكنولوجي', 'v603.1 • © Savir Technology'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.tertiaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(
    BuildContext context,
    SettingsController controller,
    _SettingsPalette palette,
  ) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return InkWell(
      onTap: () async {
        final bool? confirm = await Get.dialog<bool>(
          AlertDialog(
            backgroundColor: palette.sectionBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              t('تأكيد تسجيل الخروج', 'Confirm logout'),
              style: TextStyle(color: palette.primaryText),
            ),
            content: Text(
              t('هل أنت متأكد أنك تريد تسجيل الخروج؟', 'Are you sure you want to log out?'),
              style: TextStyle(color: palette.secondaryText),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(t('إلغاء', 'Cancel')),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB43F35),
                  foregroundColor: Colors.white,
                ),
                child: Text(t('تسجيل الخروج', 'Logout')),
              ),
            ],
          ),
        );
        if (confirm == true) {
          controller.logout();
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: palette.dangerBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.dangerBorder),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.logout_rounded, color: Color(0xFFF26A61)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                t('تسجيل الخروج', 'Logout'),
                style: const TextStyle(
                  color: Color(0xFFF26A61),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFF26A61),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _profileImage(SettingsController settings) {
    final MyServices services = Get.find<MyServices>();
    final List<String> imageCandidates = AppImageUrls.profileAvatar(
      avatarUrl: (settings.userData?['profile_image_url'] ??
              settings.userData?['avatar_url'] ??
              services.sharedPreferences.getString('avatar_url'))
          ?.toString(),
      imagePath: (settings.userData?['users_image'] ??
              services.sharedPreferences.getString('users_image'))
          ?.toString(),
    );
    final String? imageUrl =
        imageCandidates.isEmpty ? null : imageCandidates.first;

    return imageUrl != null
        ? CachedNetworkImageProvider(imageUrl)
        : const AssetImage(AppImageAsset.avatar);
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
    required this.palette,
  });

  final String title;
  final Widget child;
  final _SettingsPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.sectionBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.sectionBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: palette.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GlassSwitchTile extends StatelessWidget {
  const _GlassSwitchTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final _SettingsPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.tileBorder),
      ),
      child: SwitchListTile.adaptive(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: palette.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: palette.accent),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: palette.secondaryText),
        ),
        value: value,
        activeColor: palette.accent,
        onChanged: onChanged,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final _SettingsPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: palette.tileBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.tileBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: palette.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: palette.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.onTap,
  });

  final _SettingsPalette palette;
  final String title;
  final String subtitle;
  final String assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.tileBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.heroCardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(assetPath, width: 26, height: 26),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: palette.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: palette.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryActionTile extends StatelessWidget {
  const _LuxuryActionTile({
    required this.palette,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final _SettingsPalette palette;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.tileBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.tileBorder),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: palette.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.secondaryText,
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: palette.tertiaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.palette,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final _SettingsPalette palette;
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = filled
        ? ElevatedButton.styleFrom(
            backgroundColor: palette.accent,
            foregroundColor: const Color(0xFF17120D),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          )
        : OutlinedButton.styleFrom(
            foregroundColor: palette.primaryText,
            side: BorderSide(color: palette.tileBorder),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          );

    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );

    return filled
        ? ElevatedButton(
            onPressed: onTap,
            style: style,
            child: child,
          )
        : OutlinedButton(
            onPressed: onTap,
            style: style,
            child: child,
          );
  }
}

class _SettingsPalette {
  const _SettingsPalette({
    required this.scaffoldBackground,
    required this.backgroundGradient,
    required this.sectionBackground,
    required this.sectionBorder,
    required this.tileBackground,
    required this.tileBorder,
    required this.heroCardColor,
    required this.heroCardBorder,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.accent,
    required this.dangerBackground,
    required this.dangerBorder,
  });

  factory _SettingsPalette.fromTheme(ThemeData theme) {
    final ColorScheme colors = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return _SettingsPalette(
      scaffoldBackground: theme.scaffoldBackgroundColor,
      backgroundGradient: isDark
          ? const <Color>[
              Color(0xFF060606),
              Color(0xFF0B0B0B),
              Color(0xFF17110B),
            ]
          : <Color>[
              colors.surface,
              colors.surfaceContainerLowest,
              const Color(0xFFF6EFDE),
            ],
      sectionBackground: isDark ? const Color(0xFF151515) : colors.surface,
      sectionBorder: isDark
          ? const Color(0xFF2F271F)
          : colors.outlineVariant.withValues(alpha: 0.9),
      tileBackground:
          isDark ? const Color(0xFF1D1D1D) : colors.surfaceContainerLow,
      tileBorder: isDark
          ? const Color(0xFF32281E)
          : colors.outlineVariant.withValues(alpha: 0.95),
      heroCardColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : colors.surfaceContainerLowest.withValues(alpha: 0.92),
      heroCardBorder: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : colors.outlineVariant.withValues(alpha: 0.75),
      primaryText: colors.onSurface,
      secondaryText: colors.onSurface.withValues(alpha: 0.72),
      tertiaryText: colors.onSurface.withValues(alpha: 0.52),
      accent: const Color(0xFFD6B878),
      dangerBackground:
          isDark ? const Color(0xFF241313) : const Color(0xFFFFF1EF),
      dangerBorder: isDark ? const Color(0xFF5C2D2D) : const Color(0xFFF0B7B0),
    );
  }

  final Color scaffoldBackground;
  final List<Color> backgroundGradient;
  final Color sectionBackground;
  final Color sectionBorder;
  final Color tileBackground;
  final Color tileBorder;
  final Color heroCardColor;
  final Color heroCardBorder;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color accent;
  final Color dangerBackground;
  final Color dangerBorder;
}
