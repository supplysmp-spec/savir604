import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/theme/app_surface_palette.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;

  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    switch (statusRequest) {
      case StatusRequest.loading:
        return const _StatusScene(
          kind: _StatusKind.loading,
          icon: Icons.hourglass_top_rounded,
        );
      case StatusRequest.offlinefailure:
        return const _StatusScene(
          kind: _StatusKind.offline,
          icon: Icons.wifi_off_rounded,
        );
      case StatusRequest.serverfailure:
      case StatusRequest.serverException:
        return const _StatusScene(
          kind: _StatusKind.server,
          icon: Icons.cloud_off_rounded,
        );
      case StatusRequest.failure:
        return const _StatusScene(
          kind: _StatusKind.empty,
          icon: Icons.inventory_2_outlined,
        );
      case StatusRequest.none:
      case StatusRequest.success:
        return widget;
    }
  }
}

enum _StatusKind { loading, offline, server, empty }

class _StatusScene extends StatelessWidget {
  final _StatusKind kind;
  final IconData icon;

  const _StatusScene({
    required this.kind,
    required this.icon,
  });

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  String get _title {
    switch (kind) {
      case _StatusKind.loading:
        return _isArabic ? 'جارٍ تجهيز المحتوى' : 'Preparing your content';
      case _StatusKind.offline:
        return _isArabic ? 'لا يوجد اتصال بالإنترنت' : 'No internet connection';
      case _StatusKind.server:
        return _isArabic ? 'تعذر تحميل البيانات الآن' : 'Unable to load data right now';
      case _StatusKind.empty:
        return _isArabic ? 'لا توجد نتائج حالياً' : 'No results available';
    }
  }

  String get _message {
    switch (kind) {
      case _StatusKind.loading:
        return _isArabic
            ? 'لحظات بسيطة ونرتب لك كل شيء بشكل جميل.'
            : 'Just a moment while we get everything ready for you.';
      case _StatusKind.offline:
        return _isArabic
            ? 'تأكد من الاتصال بالإنترنت ثم حاول مرة أخرى.'
            : 'Please check your connection and try again.';
      case _StatusKind.server:
        return _isArabic
            ? 'هناك مشكلة مؤقتة، فضلاً حاول بعد قليل.'
            : 'There is a temporary issue. Please try again shortly.';
      case _StatusKind.empty:
        return _isArabic
            ? 'بمجرد توفر بيانات أو عناصر جديدة ستظهر هنا.'
            : 'New data or items will appear here when available.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = kind == _StatusKind.loading;
    final palette = AppSurfacePalette.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;

        return Container(
          width: double.infinity,
          constraints: hasBoundedHeight
              ? BoxConstraints(minHeight: constraints.maxHeight)
              : const BoxConstraints(minHeight: 280),
          alignment: Alignment.center,
          color: palette.scaffoldBackground,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: palette.border,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[
                              palette.accent.withValues(alpha: 0.22),
                              palette.cardAlt,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.2,
                                  color: const Color(0xFFD6B878),
                                ),
                              )
                            : const Icon(
                                Icons.auto_awesome_rounded,
                                size: 38,
                                color: Color(0xFFD6B878),
                              ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.secondaryText,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
