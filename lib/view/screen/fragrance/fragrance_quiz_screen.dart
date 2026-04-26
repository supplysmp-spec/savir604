import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceQuizScreen extends StatelessWidget {
  const FragranceQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();
    final Map<dynamic, dynamic>? args = Get.arguments as Map<dynamic, dynamic>?;
    final int questionIndex = (args?['index'] as int?) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            if (logic.quizLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD6B878)),
              );
            }

            if (logic.quizQuestions.isEmpty ||
                questionIndex < 0 ||
                questionIndex >= logic.quizQuestions.length) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        logic.quizError ??
                            logic.t(
                              'لا توجد أسئلة متاحة حاليًا.',
                              'No quiz questions are available right now.',
                            ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => logic.ensureQuizLoaded(force: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B878),
                          foregroundColor: const Color(0xFF1A160F),
                        ),
                        child: Text(logic.t('إعادة المحاولة', 'Retry')),
                      ),
                    ],
                  ),
                ),
              );
            }

            final FragranceQuizQuestion question = logic.quizQuestions[questionIndex];
            final double progress = (questionIndex + 1) / logic.quizQuestions.length;
            final String? selectedAnswer = logic.answerFor(questionIndex);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      InkWell(
                        onTap: logic.goBackQuiz,
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
                      const Spacer(),
                      Text(
                        '${questionIndex + 1}/${logic.quizQuestions.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD7B977)),
                    ),
                  ),
                  const SizedBox(height: 38),
                  Text(
                    question.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'myfont',
                      fontSize: 29,
                      height: 1.22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    question.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (question.helper.isNotEmpty) ...<Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF3B3125)),
                      ),
                      child: Text(
                        question.helper,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: ListView.separated(
                      itemCount: question.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (BuildContext context, int optionIndex) {
                        final FragranceQuizOption option = question.options[optionIndex];
                        final bool isSelected = selectedAnswer == option.optionId;

                        return InkWell(
                          onTap: () => logic.selectQuizAnswer(questionIndex, option.optionId),
                          borderRadius: BorderRadius.circular(22),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2A2419) : const Color(0xFF141414),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFB99859) : const Color(0xFF453727),
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    option.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFD6B878)
                                          : const Color(0xFF6A573B),
                                    ),
                                  ),
                                  child: isSelected
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
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      logic.t(
                        'إجاباتك تساعدنا على بناء توصية عطرية أدق لك',
                        'Your answers help us recommend the perfect fragrances',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.34),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAnswer == null || logic.quizSubmitting
                          ? null
                          : () => logic.continueQuiz(questionIndex),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        disabledBackgroundColor: const Color(0xFFD6B878).withValues(alpha: 0.3),
                        foregroundColor: const Color(0xFF1A160F),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        logic.quizSubmitting
                            ? logic.t('جارٍ التحليل...', 'Analyzing...')
                            : questionIndex == logic.quizQuestions.length - 1
                                ? logic.t('إنهاء', 'Finish')
                                : logic.t('متابعة', 'Continue'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
