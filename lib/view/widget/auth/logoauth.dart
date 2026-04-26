import 'package:flutter/material.dart';

class Logoauth extends StatelessWidget {
  const Logoauth({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double size = width > 900 ? 160 : 88;

    return SizedBox(
      height: size + 22,
      width: size + 22,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size + 10,
            height: size + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.12),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFD6B878).withValues(alpha: 0.22),
                  blurRadius: 28,
                ),
              ],
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.45,
                height: size * 0.72,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      child: Container(
                        width: size * 0.18,
                        height: size * 0.18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9BE83),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      top: size * 0.14,
                      child: Container(
                        width: size * 0.42,
                        height: size * 0.50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              const Color(0xFFE2C98F).withValues(alpha: 0.66),
                              const Color(0xFFC39D5C).withValues(alpha: 0.24),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFEACD90).withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
