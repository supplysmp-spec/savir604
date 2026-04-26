import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/archive/orders_archive_controller.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/controler/settings/settings_controller.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/orders_archive_model.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class OrdersArchivePagee extends StatelessWidget {
  const OrdersArchivePagee({super.key});

  @override
  Widget build(BuildContext context) {
    final OrdersArchiveControllerr controller = Get.put(
      OrdersArchiveControllerr(),
    );
    final SettingsController settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    final MyServices services = Get.find<MyServices>();
    final ThemeData theme = Theme.of(context);

    final List<String> profileImageUrls = AppImageUrls.profileAvatar(
      avatarUrl: (settings.userData?['profile_image_url'] ??
              settings.userData?['avatar_url'] ??
              services.sharedPreferences.getString('avatar_url'))
          ?.toString(),
      imagePath: (settings.userData?['users_image'] ??
              services.sharedPreferences.getString('users_image'))
          ?.toString(),
    );
    final String displayName = ((settings.userData?['display_name'] ??
                settings.userData?['users_name'] ??
                services.sharedPreferences.getString('display_name') ??
                services.sharedPreferences.getString('users_name') ??
                'Member')
            .toString())
        .trim();
    final String username = ((settings.userData?['username'] ??
                services.sharedPreferences.getString('username') ??
                '')
            .toString())
        .trim();

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF060606),
              Color(0xFF0B0B0B),
              Color(0xFF17110B),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => RefreshIndicator(
              onRefresh: () => controller.fetchOrdersArchive(controller.userId),
              color: const Color(0xFFD6B878),
              backgroundColor: const Color(0xFF171717),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: <Widget>[
                  _ArchiveHero(
                    profileImageUrls: profileImageUrls,
                    displayName: displayName,
                    username: username,
                    orderCount: controller.ordersList.length,
                    totalSpent: _totalSpent(controller.ordersList),
                  ),
                  const SizedBox(height: 18),
                  if (controller.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD6B878),
                        ),
                      ),
                    )
                  else if (controller.errorMessage.value.isNotEmpty)
                    _ArchiveError(
                      message: controller.errorMessage.value,
                      onRetry: () =>
                          controller.fetchOrdersArchive(controller.userId),
                    )
                  else if (controller.ordersList.isEmpty)
                    const _EmptyArchive()
                  else ...<Widget>[
                    const _ArchiveSectionTitle(
                      title: 'Archived Pieces',
                      subtitle:
                          'Every completed order stays here with its price, quantity, and selected details.',
                    ),
                    const SizedBox(height: 14),
                    ...controller.ordersList.map(
                      (OrdersArchiveModel order) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ArchiveCard(order: order),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _totalSpent(List<OrdersArchiveModel> orders) {
    double total = 0;
    for (final OrdersArchiveModel order in orders) {
      total += double.tryParse(order.ordersTotalprice) ?? 0;
    }
    return CurrencyFormatter.egp(total);
  }
}

class _ArchiveHero extends StatelessWidget {
  const _ArchiveHero({
    required this.profileImageUrls,
    required this.displayName,
    required this.username,
    required this.orderCount,
    required this.totalSpent,
  });

  final List<String> profileImageUrls;
  final String displayName;
  final String username;
  final int orderCount;
  final String totalSpent;

  @override
  Widget build(BuildContext context) {
    return AppTopBanner(
      title: 'Order Archive',
      subtitle:
          'A polished record of every completed purchase, ready whenever you want to revisit a favorite piece.',
      leadingIcon: Icons.arrow_back_rounded,
      onLeadingTap: Get.back,
      trailingIcon: Icons.history_toggle_off_rounded,
      onTrailingTap: () {},
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: <Widget>[
                ClipOval(
                  child: FallbackNetworkImage(
                    imageUrls: profileImageUrls,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    label: displayName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        username.isEmpty
                            ? 'Your saved order story'
                            : '@${username.replaceAll('@', '')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.72),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: AppTopBannerMetric(
                  value: '$orderCount',
                  label: 'Archived orders',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTopBannerMetric(
                  value: totalSpent,
                  label: 'Total collected',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArchiveSectionTitle extends StatelessWidget {
  const _ArchiveSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'myfont',
            fontSize: 30,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ArchiveError extends StatelessWidget {
  const _ArchiveError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF171311),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF4D2C2B)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF26A61).withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFF26A61),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Could not load archive',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD6B878),
              foregroundColor: const Color(0xFF17120D),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF31281F)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFD6B878),
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No archived orders yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Once your orders are completed, they will appear here in a cleaner and more collectible layout.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({required this.order});

  final OrdersArchiveModel order;

  @override
  Widget build(BuildContext context) {
    final double price = double.tryParse(order.itemPrice) ?? 0;
    final double discount = double.tryParse(order.itemDiscount) ?? 0;
    final int quantity = int.tryParse(order.quantity) ?? 1;
    final double frameOnlyTotal = (price - (price * discount / 100)) * quantity;
    final double lensTotal = double.tryParse(order.lensTotalPrice) ?? 0;
    final double finalPrice =
        double.tryParse(order.lineTotal) ?? (frameOnlyTotal + lensTotal);
    final bool hasLenses = order.lensName.trim().isNotEmpty;
    final bool hasVariantDetails =
        order.itemColor.trim().isNotEmpty || order.itemSize.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF31281F)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FallbackNetworkImage(
                  imageUrls: AppImageUrls.item(order.itemsImage),
                  width: 92,
                  height: 110,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    width: 92,
                    height: 110,
                    color: const Color(0xFF101010),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFFD6B878),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            order.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CapsuleLabel(label: '#${order.ordersId}'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _InlineTag(
                          icon: Icons.inventory_2_outlined,
                          text: 'Qty $quantity',
                        ),
                        _InlineTag(
                          icon: Icons.payments_outlined,
                          text: CurrencyFormatter.egp(finalPrice),
                          emphasized: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatArchiveDate(order.ordersDatetime),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.48),
                        fontSize: 13,
                      ),
                    ),
                    if (hasVariantDetails) ...<Widget>[
                      const SizedBox(height: 10),
                      Text(
                        'Color: ${order.itemColor.isEmpty ? '-' : order.itemColor}   Size: ${order.itemSize.isEmpty ? '-' : order.itemSize}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (hasLenses) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Add-on: ${order.lensName}',
                        style: const TextStyle(
                          color: Color(0xFFD6B878),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF2A221B)),
            ),
            child: Column(
              children: <Widget>[
                _PriceRow(
                  label: 'Base price',
                  value: CurrencyFormatter.egp(double.tryParse(order.itemPrice) ?? 0),
                ),
                const SizedBox(height: 8),
                _PriceRow(label: 'Discount', value: '${order.itemDiscount}%'),
                if (hasLenses) ...<Widget>[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Add-on unit',
                    value: CurrencyFormatter.egp(
                      double.tryParse(order.lensUnitPrice) ?? 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Add-on total',
                    value: CurrencyFormatter.egp(lensTotal),
                  ),
                  if (order.lensColor.trim().isNotEmpty) ...<Widget>[
                    const SizedBox(height: 8),
                    _PriceRow(label: 'Add-on color', value: order.lensColor),
                  ],
                ],
                const SizedBox(height: 8),
                _PriceRow(
                  label: 'Final total',
                  value: CurrencyFormatter.egp(finalPrice),
                  highlight: true,
                ),
                if (hasLenses && order.prescriptionSummary.trim().isNotEmpty) ...<
                    Widget>[
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'Details: ${order.prescriptionSummary}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        height: 1.45,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleLabel extends StatelessWidget {
  const _CapsuleLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD6B878).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD6B878),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  const _InlineTag({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        emphasized ? const Color(0xFFD6B878) : Colors.white70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: emphasized
            ? const Color(0xFFD6B878).withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized
              ? const Color(0xFFD6B878).withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.66),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFD6B878) : Colors.white,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _formatArchiveDate(String raw) {
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  if (trimmed.length >= 16) {
    return trimmed.substring(0, 16).replaceFirst('T', ' ');
  }
  return trimmed;
}
