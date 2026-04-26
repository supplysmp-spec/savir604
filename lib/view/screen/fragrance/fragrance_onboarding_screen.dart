import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceOnboardingScreen extends StatelessWidget {
  const FragranceOnboardingScreen({super.key});

  static const List<String> _slideImages = <String>[
    'assets/images/on1.png',
    'assets/images/on2.png',
    'assets/images/on3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final FragranceFlowController controller = ensureFragranceFlowController();

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GetBuilder<FragranceFlowController>(
          init: controller,
          builder: (FragranceFlowController logic) {
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: <Widget>[
                      const Spacer(),
                      TextButton(
                        onPressed: logic.skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: logic.onboardingController,
                    itemCount: logic.introSlides.length,
                    onPageChanged: logic.setOnboardingIndex,
                    itemBuilder: (BuildContext context, int index) {
                      final FragranceIntroSlide slide = logic.introSlides[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _OnboardingArt(
                              icon: slide.icon,
                              index: index,
                              imageAsset: _slideImages[index],
                            ),
                            const SizedBox(height: 30),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'myfont',
                                fontSize: 30,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          logic.introSlides.length,
                          (int index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: logic.onboardingIndex == index ? 28 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: logic.onboardingIndex == index
                                  ? const Color(0xFFD8B977)
                                  : Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: logic.nextOnboardingPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD6B878),
                            foregroundColor: const Color(0xFF15120D),
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                logic.introSlides[logic.onboardingIndex].buttonLabel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingArt extends StatelessWidget {
  const _OnboardingArt({
    required this.icon,
    required this.index,
    required this.imageAsset,
  });

  final IconData icon;
  final int index;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> palettes = <List<Color>>[
      <Color>[const Color(0xFFC3D7EE), const Color(0xFFEED6C6)],
      <Color>[const Color(0xFFF0F0F0), const Color(0xFFC2162C)],
      <Color>[const Color(0xFF131313), const Color(0xFF2C2C2C)],
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          width: 286,
          height: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: palettes[index],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: palettes[index].last.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
              image: DecorationImage(
                image: AssetImage(imageAsset),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.14),
                  ],
                ),
              ),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 18),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFD6B878).withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1A160F), size: 30),
          ),
        ),
      ],
    );
  }
}
