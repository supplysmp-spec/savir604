import 'package:flutter/material.dart';
import 'package:tks/core/constant/color.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class CustomItemsCartList extends StatelessWidget {
  final String name;
  final String price;
  final String count;
  final String imagename;
  final String? subtitle;
  final void Function()? onAdd;
  final void Function()? onRemove;

  const CustomItemsCartList({
    super.key,
    required this.name,
    required this.price,
    required this.count,
    required this.imagename,
    this.subtitle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
            child: SizedBox(
              width: 112,
              height: 138,
              child: FallbackNetworkImage(
                imageUrls: AppImageUrls.item(imagename),
                fit: BoxFit.cover,
                placeholder: Container(
                  color: colors.primary.withValues(alpha: 0.08),
                ),
                errorWidget: Container(
                  color: colors.primary.withValues(alpha: 0.08),
                  child: Icon(Icons.image_not_supported_outlined,
                      color: colors.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ColorApp.praimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _qtyButton(
                          icon: Icons.remove_rounded,
                          onTap: onRemove,
                          context: context,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          count,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _qtyButton(
                          icon: Icons.add_rounded,
                          onTap: onAdd,
                          context: context,
                          filled: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required BuildContext context,
    required IconData icon,
    required void Function()? onTap,
    bool filled = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled ? colors.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? colors.onPrimary : colors.primary,
        ),
      ),
    );
  }
}
