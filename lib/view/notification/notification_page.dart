import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/notification_con.dart';
import 'package:tks/core/functions/notification_navigation.dart';
import 'package:tks/core/theme/app_surface_palette.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());
    final palette = AppSurfacePalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Row(
                children: <Widget>[
                  _circleButton(
                    context,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: Get.back,
                  ),
                  Expanded(
                    child: Text(
                      'Notifications',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.primaryText,
                        fontFamily: 'myfont',
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Obx(
                    () => TextButton(
                      onPressed:
                          controller.unreadCount == 0 ? null : controller.markAllAsRead,
                      child: const Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Color(0xFFD6B878),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.notifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFD6B878)),
                  );
                }

                final items = controller.notifications;
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: palette.secondaryText,
                        fontSize: 18,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: palette.accent,
                  backgroundColor: palette.card,
                  onRefresh: controller.fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (BuildContext context, int index) {
                      final item = items[index];
                      final _NotifVisual visual = _visualForType(item.type);

                      return InkWell(
                        onTap: () async {
                          await controller.markAsRead(item.id);
                          _openNotification(item);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: palette.cardAlt,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: item.isRead
                                  ? palette.border
                                  : palette.accent.withValues(alpha: 0.45),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: visual.iconBg,
                                ),
                                child: Icon(visual.icon, color: visual.iconColor),
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
                                            item.title,
                                            style: TextStyle(
                                              color: palette.primaryText,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (!item.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFD6B878),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.body,
                                      style: TextStyle(
                                        color: palette.secondaryText,
                                        height: 1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      _timeAgo(item.createdAt),
                                      style: TextStyle(
                                        color: palette.tertiaryText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.close_rounded, color: palette.tertiaryText),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(String raw) {
    try {
      final DateTime parsed = DateTime.parse(raw).toLocal();
      final Duration diff = DateTime.now().difference(parsed);
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return raw;
    }
  }

  void _openNotification(AppNotificationItem item) {
    NotificationNavigation.openNotificationItem(item);
  }

  _NotifVisual _visualForType(String type) {
    switch (type) {
      case 'new_follower':
        return const _NotifVisual(
          icon: Icons.person_add_alt_1_rounded,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      case 'order_status':
      case 'payment_status':
        return const _NotifVisual(
          icon: Icons.shopping_bag_outlined,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      case 'admin_chat':
      case 'direct_message':
        return const _NotifVisual(
          icon: Icons.mark_chat_unread_outlined,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      case 'new_post':
      case 'post_like':
      case 'post_comment':
        return const _NotifVisual(
          icon: Icons.dynamic_feed_rounded,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      case 'new_product':
        return const _NotifVisual(
          icon: Icons.notifications_none_rounded,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      case 'new_video':
      case 'comment_reply':
      case 'comment_like':
        return const _NotifVisual(
          icon: Icons.play_circle_outline_rounded,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
      default:
        return const _NotifVisual(
          icon: Icons.card_giftcard_outlined,
          iconBg: Color(0xFF38332A),
          iconColor: Color(0xFFD6B878),
        );
    }
  }

  Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final palette = AppSurfacePalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.card,
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.accent, size: 18),
      ),
    );
  }
}

class _NotifVisual {
  const _NotifVisual({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}
