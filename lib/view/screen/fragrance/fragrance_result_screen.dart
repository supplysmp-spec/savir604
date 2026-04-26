import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';
import 'package:tks/core/constant/routes.dart';

class FragranceResultScreen extends StatelessWidget {
  const FragranceResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();
    final String Function(String, String) t = controller.t;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            final FragranceProfileResult result = logic.profileResult;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFFE9CF94), Color(0xFFD0A95E)],
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: const Color(0xFFD6B878).withValues(alpha: 0.32),
                            blurRadius: 26,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 42,
                        color: Color(0xFF1A160F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      t('ملفك العطري', 'Your Fragrance Profile'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 31,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      t(
                        'أنشأنا لك توصية عطرية مخصصة بناءً على إجاباتك',
                        "We've created your personalized fragrance journey",
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFFD2AE69).withValues(alpha: 0.92),
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _ResultCard(
                    title: t('نوع الشخصية', 'Personality Type'),
                    child: Text(
                      result.personalityType,
                      style: const TextStyle(
                        color: Color(0xFFD4B06B),
                        fontFamily: 'myfont',
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ResultCard(
                    title: t('النوتات المقترحة', 'Recommended Notes'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: result.recommendedNotes
                          .map((String note) => _GoldPill(label: note))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ResultCard(
                    title: t('العائلات العطرية', 'Fragrance Families'),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: result.fragranceFamilies
                          .map((String family) => _GoldPill(label: family))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ResultCard(
                    title: t('أسلوبك العطري', 'Your Signature Style'),
                    child: Text(
                      result.signatureStyle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.84),
                        fontSize: 17,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.fragranceBuilder),
                      icon: const Icon(Icons.science_outlined),
                      label: Text(t('اصنع عطرك', 'Build Your Perfume')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD6B878),
                        side: const BorderSide(color: Color(0xFF57452D)),
                        backgroundColor: const Color(0xFF242321),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed(AppRoutes.homepage),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(t('ابدأ التسوق', 'Start Shopping')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        foregroundColor: const Color(0xFF1A160F),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF322B23)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GoldPill extends StatelessWidget {
  const _GoldPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: const Color(0xFF3A332A),
        border: Border.all(color: const Color(0xFF57452D)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD5B06B),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
