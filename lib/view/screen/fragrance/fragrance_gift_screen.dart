import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';
import 'package:tks/view/screen/fragrance/fragrance_selection_screen.dart';

class FragranceGiftScreen extends StatelessWidget {
  const FragranceGiftScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.auto_awesome, color: const Color(0xFFD8B977).withValues(alpha: 0.9)),
                      const Spacer(),
                      Icon(Icons.auto_awesome, color: const Color(0xFFD8B977).withValues(alpha: 0.9)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Who is the gift for?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 30,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      "We'll help you find the perfect fragrance",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SelectionOptionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Gift for Him',
                    selected: logic.selectedGiftType == 'him',
                    onTap: () => logic.chooseGiftType('him'),
                  ),
                  const SizedBox(height: 20),
                  SelectionOptionCard(
                    icon: Icons.person_2_outlined,
                    title: 'Gift for Her',
                    selected: logic.selectedGiftType == 'her',
                    onTap: () => logic.chooseGiftType('her'),
                  ),
                  const SizedBox(height: 20),
                  SelectionOptionCard(
                    icon: Icons.psychology_alt_outlined,
                    title: 'Help me choose',
                    selected: logic.selectedGiftType == 'help',
                    onTap: () => logic.chooseGiftType('help'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFFC2B5A3)),
                    label: const Text(
                      'Back to selection',
                      style: TextStyle(color: Color(0xFFC2B5A3), fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: logic.selectedGiftType == null
                          ? null
                          : () async {
                              await logic.continueFromGift();
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
