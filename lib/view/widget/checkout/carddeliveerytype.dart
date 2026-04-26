import 'package:flutter/material.dart';

class CardDeliveryTypeCheckout extends StatelessWidget {
  final String imagename;
  final String title;
  final String? subtitle;
  final bool active;

  const CardDeliveryTypeCheckout({
    super.key,
    required this.imagename,
    required this.title,
    this.subtitle,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? colors.primary.withValues(alpha: 0.08) : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: active ? colors.primary : theme.dividerColor.withValues(alpha: 0.35),
          width: active ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active ? colors.primary.withValues(alpha: 0.12) : theme.cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.asset(imagename, color: colors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (active)
            Icon(Icons.check_circle_rounded, color: colors.primary),
        ],
      ),
    );
  }
}
