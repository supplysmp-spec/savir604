import 'package:flutter/material.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/currency_formatter.dart';

class PriceAndCountItems extends StatelessWidget {
  final void Function()? onAdd;
  final void Function()? onRemove;
  final String price;
  final String count;
  final bool canAdd;

  const PriceAndCountItems({
    super.key,
    required this.onAdd,
    required this.onRemove,
    required this.price,
    required this.count,
    this.canAdd = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              _buildIconButton(
                icon: Icons.remove_rounded,
                onPressed: onRemove,
                background: colors.primary.withValues(alpha: 0.08),
                color: colors.primary,
              ),
              Container(
                width: 56,
                alignment: Alignment.center,
                child: Text(
                  count,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildIconButton(
                icon: Icons.add_rounded,
                onPressed: canAdd ? onAdd : null,
                background: canAdd
                    ? ColorApp.praimaryColor
                    : colors.onSurface.withValues(alpha: 0.10),
                color: canAdd
                    ? Colors.white
                    : colors.onSurface.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          CurrencyFormatter.egp(double.tryParse(price) ?? 0),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required void Function()? onPressed,
    required Color background,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
