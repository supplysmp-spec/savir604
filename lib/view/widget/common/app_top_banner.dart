import 'package:flutter/material.dart';
import 'package:tks/core/theme/app_surface_palette.dart';

class AppTopBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final Widget? child;

  const AppTopBanner({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    this.onLeadingTap,
    this.trailingIcon,
    this.onTrailingTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppSurfacePalette.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.cardAlt,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -18,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : palette.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BannerButton(
                    icon: leadingIcon,
                    onTap: onLeadingTap,
                  ),
                  const Spacer(),
                  if (trailingIcon != null)
                    _BannerButton(
                      icon: trailingIcon!,
                      onTap: onTrailingTap,
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((subtitle ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.secondaryText,
                    height: 1.45,
                  ),
                ),
              ],
              if (child != null) ...[
                const SizedBox(height: 18),
                child!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _BannerButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: palette.isDark
              ? Colors.white.withValues(alpha: 0.10)
              : palette.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.primaryText),
      ),
    );
  }
}

class AppTopBannerMetric extends StatelessWidget {
  final String value;
  final String label;

  const AppTopBannerMetric({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppSurfacePalette.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: palette.primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
