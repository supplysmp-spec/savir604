import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/fragrance/fragrance_flow_controller.dart';

class FragranceSplashScreen extends StatefulWidget {
  const FragranceSplashScreen({super.key});

  @override
  State<FragranceSplashScreen> createState() => _FragranceSplashScreenState();
}

class _FragranceSplashScreenState extends State<FragranceSplashScreen> {
  late final FragranceFlowController controller;

  @override
  void initState() {
    super.initState();
    controller = ensureFragranceFlowController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.routeFromSplash();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B0B0B),
      body: _FragranceSplashBody(),
    );
  }
}

class _FragranceSplashBody extends StatelessWidget {
  const _FragranceSplashBody();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  const Color(0xFF050505),
                  const Color(0xFF0B0B0B),
                  const Color(0xFF16110C),
                ],
              ),
            ),
          ),
        ),
        const _GoldParticles(),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const _PerfumeBottleGlow(),
                  const SizedBox(height: 32),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: <Color>[Color(0xFFF7E4B1), Color(0xFFC8A96A)],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Precious',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'myfont',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FRAGRANCE',
                    style: TextStyle(
                      color: Color(0xFFE4C78A),
                      letterSpacing: 6,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Where luxury meets personality',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PerfumeBottleGlow extends StatelessWidget {
  const _PerfumeBottleGlow();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(scale: value, child: child);
      },
      child: SizedBox(
        width: 150,
        height: 245,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC8A96A).withValues(alpha: 0.16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFC8A96A).withValues(alpha: 0.25),
                    blurRadius: 80,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                width: 56,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9BE83),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              top: 62,
              child: Container(
                width: 28,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D7546),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Positioned(
              top: 78,
              child: Container(
                width: 90,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      const Color(0xFFD7C08E).withValues(alpha: 0.44),
                      const Color(0xFFB69358).withValues(alpha: 0.22),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE0C48A).withValues(alpha: 0.28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoldParticles extends StatelessWidget {
  const _GoldParticles();

  @override
  Widget build(BuildContext context) {
    const List<Offset> positions = <Offset>[
      Offset(0.12, 0.18),
      Offset(0.25, 0.22),
      Offset(0.18, 0.64),
      Offset(0.78, 0.2),
      Offset(0.84, 0.32),
      Offset(0.7, 0.74),
      Offset(0.1, 0.84),
      Offset(0.9, 0.62),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: positions
              .map(
                (Offset offset) => Positioned(
                  left: constraints.maxWidth * offset.dx,
                  top: constraints.maxHeight * offset.dy,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFDABD7A).withValues(alpha: 0.8),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFC8A96A).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
