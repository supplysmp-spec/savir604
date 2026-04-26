import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/onbourding/onbording_controler.dart';
import 'package:tks/data/static/static.dart';

class OnBoarding extends StatelessWidget {
  const OnBoarding({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OnBordingControlerImp());
    final theme = Theme.of(context);
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GetBuilder<OnBordingControlerImp>(
        builder: (controller) {
          final isLast = controller.currentPage == onbordinglist.length - 1;

          return Container(
            color: isDark ? const Color(0xFF151515) : const Color(0xFFFAFAF7),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Text(
                            '${controller.currentPage + 1}/${onbordinglist.length}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: controller.skip,
                          child: Text(
                            isArabic ? 'تخطي' : 'Skip',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: onbordinglist.length,
                      itemBuilder: (context, index) {
                        final item = onbordinglist[index];

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1B1B1B),
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Center(
                                      child: Image.asset(
                                        item.images!,
                                        fit: BoxFit.contain,
                                        filterQuality: FilterQuality.high,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF252525)
                                                : const Color(0xFFF1F1EC),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            item.badge ??
                                                (isArabic
                                                    ? 'الخطوة ${index + 1}'
                                                    : 'Step ${index + 1}'),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          item.title!,
                                          style: theme.textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            height: 1.12,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          item.body!,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            height: 1.5,
                                            color: theme.textTheme.bodyLarge?.color
                                                ?.withValues(alpha: 0.82),
                                          ),
                                        ),
                                        if (item.highlights.isNotEmpty) ...[
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: item.highlights
                                                .map(
                                                  (highlight) => Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(0xFF252525)
                                                          : const Color(0xFFF1F1EC),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Text(
                                                      highlight,
                                                      style: theme.textTheme.bodySmall?.copyWith(
                                                        color: theme.colorScheme.onSurface,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: List.generate(
                              onbordinglist.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsetsDirectional.only(end: 8),
                                width: controller.currentPage == index ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: controller.currentPage == index
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton(
                          onPressed: controller.next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: const Size(154, 58),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast
                                    ? (isArabic ? 'ابدأ الآن' : 'Get started')
                                    : (isArabic ? 'التالي' : 'Next'),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
