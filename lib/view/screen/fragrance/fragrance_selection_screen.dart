import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceSelectionScreen extends StatelessWidget {
  const FragranceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 8),
                  const Text(
                    'Who is this fragrance for?',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'myfont',
                      fontSize: 31,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Let's personalize your experience",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SelectionOptionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'For Men',
                    selected: logic.selectedAudience == 'men',
                    onTap: () => logic.chooseAudience('men'),
                  ),
                  const SizedBox(height: 20),
                  SelectionOptionCard(
                    icon: Icons.person_2_outlined,
                    title: 'For Women',
                    selected: logic.selectedAudience == 'women',
                    onTap: () => logic.chooseAudience('women'),
                  ),
                  const SizedBox(height: 20),
                  SelectionOptionCard(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Gift',
                    selected: logic.selectedAudience == 'gift',
                    onTap: () => logic.chooseAudience('gift'),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      "Don't worry, you can explore all categories later",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: logic.selectedAudience == null
                          ? null
                          : () async {
                              await logic.continueFromAudience();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        disabledBackgroundColor: const Color(0xFFD6B878).withValues(alpha: 0.3),
                        foregroundColor: const Color(0xFF1A160F),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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

class SelectionOptionCard extends StatelessWidget {
  const SelectionOptionCard({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 94,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A2419) : const Color(0xFF181512),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFB99859) : const Color(0xFF443726),
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFC8A96A).withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFD6B878),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: const Color(0xFF18140F), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFFD6B878) : const Color(0xFF63523A),
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: Color(0xFFD6B878),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
