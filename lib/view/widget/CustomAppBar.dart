// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String titleappbar;
  final void Function()? onPressedSearch;
  final void Function()? onPressedIconFavorite;
  final TextEditingController mycontroller;

  const CustomAppBar({
    super.key,
    required this.titleappbar,
    required this.mycontroller,
    this.onPressedSearch,
    this.onPressedIconFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.85),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: mycontroller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onPressedSearch?.call(),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                ),
                hintText: titleappbar,
                hintStyle: theme.textTheme.bodyMedium,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.tune_rounded,
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          onTap: onPressedSearch,
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.favorite_rounded,
          foregroundColor: colors.error,
          backgroundColor: theme.cardColor,
          onTap: onPressedIconFavorite,
          borderColor: theme.dividerColor.withValues(alpha: 0.85),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color? borderColor;
  final void Function()? onTap;

  const _ActionButton({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor == null ? null : Border.all(color: borderColor!),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: foregroundColor),
      ),
    );
  }
}
