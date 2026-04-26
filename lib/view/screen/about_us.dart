import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary.withValues(alpha: 0.08),
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              AppTopBanner(
                title: 'حول التطبيق',
                subtitle:
                    'تعرف على Savir Technology، رؤيتنا، والخدمات التي نقدمها لدعم المتاجر الرقمية.',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: Get.back,
                trailingIcon: Icons.info_outline_rounded,
                onTrailingTap: () {},
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Savir Technology',
                body:
                    'نحن منصة تقنية متخصصة في تطوير المتاجر الإلكترونية وتجهيز تجربة بيع حديثة، سريعة، وسهلة الإدارة لأصحاب الأنشطة التجارية.',
              ),
              const SizedBox(height: 14),
              _sectionCard(
                context,
                title: 'رؤيتنا',
                body:
                    'أن نكون شريك النمو الرقمي الأول لكل نشاط يريد الانتقال إلى تجربة بيع احترافية تجمع بين التصميم الجيد، الأداء، وسهولة الاستخدام.',
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خدماتنا', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 14),
                      _serviceTile(
                        context,
                        icon: FontAwesomeIcons.shop,
                        title: 'تصميم وتطوير المتاجر الإلكترونية',
                      ),
                      const SizedBox(height: 10),
                      _serviceTile(
                        context,
                        icon: FontAwesomeIcons.mobileScreen,
                        title: 'تطبيقات مخصصة لكل نشاط تجاري',
                      ),
                      const SizedBox(height: 10),
                      _serviceTile(
                        context,
                        icon: FontAwesomeIcons.gears,
                        title: 'دعم فني وصيانة مستمرة',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('تواصل معنا', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 14),
                      _contactRow(
                        context,
                        icon: Icons.email_outlined,
                        text: 'support@savir.site',
                      ),
                      const SizedBox(height: 10),
                      _contactRow(
                        context,
                        icon: Icons.phone_android_outlined,
                        text: '+20 1112608734 - +20 1065145794',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Savir Technology © 2025',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required String title, required String body}) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.7)),
          ],
        ),
      ),
    );
  }

  Widget _serviceTile(BuildContext context, {required IconData icon, required String title}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _contactRow(BuildContext context, {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, color: colors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
