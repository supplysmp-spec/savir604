import 'package:flutter/material.dart';

class CardShppingAddressCheckout extends StatelessWidget {
  final String title;
  final String body;
  final bool isactive;

  const CardShppingAddressCheckout({
    super.key,
    required this.title,
    required this.body,
    required this.isactive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isactive ? colors.primary.withValues(alpha: 0.08) : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isactive ? colors.primary : theme.dividerColor.withValues(alpha: 0.35),
          width: isactive ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isactive ? colors.primary.withValues(alpha: 0.12) : theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.location_on_outlined, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          if (isactive)
            Icon(Icons.check_circle_rounded, color: colors.primary),
        ],
      ),
    );
  }
}
