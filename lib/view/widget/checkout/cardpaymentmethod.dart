import 'package:flutter/material.dart';

class CardPaymentMethodCheckout extends StatelessWidget {
  final String title;
  final bool isActive;
  final IconData icon;

  const CardPaymentMethodCheckout({
    super.key,
    required this.title,
    required this.isActive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? colors.primary : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? colors.primary : theme.dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: isActive ? Colors.white : colors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isActive ? Colors.white : theme.textTheme.titleMedium?.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
