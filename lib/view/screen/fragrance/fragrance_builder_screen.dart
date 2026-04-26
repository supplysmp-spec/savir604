import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceBuilderScreen extends StatelessWidget {
  const FragranceBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();
    final Map<dynamic, dynamic>? args = Get.arguments as Map<dynamic, dynamic>?;
    final int requestedStep = (args?['step'] as int?) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            final List<List<FragranceBuilderOption>> steps = logic.builderSteps;
            final int lastStep = steps.isEmpty ? 0 : steps.length - 1;
            final int safeStep = requestedStep.clamp(0, lastStep).toInt();
            final List<FragranceBuilderOption> options =
                steps.isEmpty ? const <FragranceBuilderOption>[] : steps[safeStep];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF433727)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFFD2B06D),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Build Your Perfume',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'myfont',
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: List<Widget>.generate(
                      logic.builderStepsCount,
                      (int index) {
                        final bool active = index == safeStep;
                        final bool completed = index < safeStep;
                        return Expanded(
                          child: Row(
                            children: <Widget>[
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active
                                      ? const Color(0xFFD6B878)
                                      : completed
                                          ? const Color(0xFF433727)
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: const Color(0xFFD6B878),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: active
                                          ? const Color(0xFF1A160F)
                                          : const Color(0xFFD6B878),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              if (index != logic.builderStepsCount - 1)
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    color: const Color(0xFFD6B878),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    height: 2,
                    color: const Color(0xFF2E281F),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: !logic.pricingConfigLoaded
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD6B878),
                            ),
                          )
                        : options.isEmpty
                            ? Center(
                                child: Text(
                                  'No fragrance options are available yet.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                itemCount: options.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1.25,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  final FragranceBuilderOption option =
                                      options[index];
                                  final bool selected = logic.isBuilderSelected(
                                    safeStep,
                                    option.name,
                                  );

                                  return InkWell(
                                    onTap: () => logic.toggleBuilderSelection(
                                      safeStep,
                                      option.name,
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 220),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? const Color(0xFF2D271E)
                                            : const Color(0xFF101010),
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        border: Border.all(
                                          color: selected
                                              ? const Color(0xFFD6B878)
                                              : const Color(0xFF30291F),
                                          width: selected ? 1.6 : 1,
                                        ),
                                      ),
                                      child: Stack(
                                        children: <Widget>[
                                          if (selected)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                width: 24,
                                                height: 24,
                                                decoration:
                                                    const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFD6B878),
                                                ),
                                                child: const Icon(
                                                  Icons.star_rounded,
                                                  size: 14,
                                                  color: Color(0xFF1A160F),
                                                ),
                                              ),
                                            ),
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                  Icons.auto_awesome,
                                                  color: selected
                                                      ? const Color(0xFFD6B878)
                                                      : Colors.white.withValues(
                                                          alpha: 0.40),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  option.name,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(
                                                      alpha:
                                                          selected ? 1 : 0.82,
                                                    ),
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600,
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
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: logic.canContinueBuilderStep(safeStep)
                          ? () => logic.continueBuilderStep(safeStep)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        disabledBackgroundColor: const Color(0xFF2F2F2F),
                        foregroundColor: const Color(0xFF1A160F),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        safeStep == logic.builderStepsCount - 1
                            ? 'Create Perfume'
                            : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
