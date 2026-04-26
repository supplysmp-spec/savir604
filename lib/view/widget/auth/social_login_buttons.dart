import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
  });

  final VoidCallback onGoogleTap;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    String t(String ar, String en) => isArabic ? ar : en;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Divider(color: const Color(0xFFD7C7AD).withValues(alpha: 0.95))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                t('أو المتابعة عبر', 'or continue with'),
                style: const TextStyle(
                  color: Color(0xFF736454),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: const Color(0xFFD7C7AD).withValues(alpha: 0.95))),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _SocialButton(
            label: t('المتابعة باستخدام Google', 'Continue with Google'),
            icon: FontAwesomeIcons.google,
            color: const Color(0xFFDB4437),
            onTap: onGoogleTap,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFCF8),
        side: const BorderSide(color: Color(0xFFE0D2BC)),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      icon: FaIcon(icon, size: 16, color: color),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF241E18),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
