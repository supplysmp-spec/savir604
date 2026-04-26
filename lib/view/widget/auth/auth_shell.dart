import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/core/theme/app_surface_palette.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.hero,
    this.badge = 'Precious Fragrance',
    this.caption = 'Private fragrance access',
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget hero;
  final String badge;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool wide = constraints.maxWidth >= 920;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: palette.screenGradient,
              ),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned.fill(child: _AuthAtmosphere()),
                SafeArea(
                  child: wide
                      ? _WideAuthLayout(
                          title: title,
                          subtitle: subtitle,
                          form: form,
                          hero: hero,
                          badge: badge,
                          caption: caption,
                        )
                      : _MobileAuthLayout(
                          title: title,
                          subtitle: subtitle,
                          form: form,
                          hero: hero,
                          badge: badge,
                          caption: caption,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileAuthLayout extends StatelessWidget {
  const _MobileAuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.hero,
    required this.badge,
    required this.caption,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget hero;
  final String badge;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _Reveal(
            delay: 0,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: authHeroDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _AuthBadge(label: badge),
                      const Spacer(),
                      const _MiniSparkle(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      hero,
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'myfont',
                                fontSize: 24,
                                height: 1.08,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.70),
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: const Color(0xFF4A3A22)),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6B878).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFF2D89C),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            caption,
                            style: TextStyle(
                              color: const Color(0xFFE6C98D).withValues(alpha: 0.92),
                              fontSize: 12,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -18),
            child: _Reveal(
              delay: 120,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xFFF8F4EC),
                      Color(0xFFF4EDE2),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(34),
                    topRight: Radius.circular(34),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x3B000000),
                      blurRadius: 28,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFFE2C98F), Color(0xFFC9AE74)],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 16),
                      form,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WideAuthLayout extends StatelessWidget {
  const _WideAuthLayout({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.hero,
    required this.badge,
    required this.caption,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget hero;
  final String badge;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: _Reveal(
            delay: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                color: const Color(0xFFF7F1E6).withValues(alpha: 0.92),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 42,
                    offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(34),
                      decoration: authHeroDecoration(radius: 38),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              _AuthBadge(label: badge),
                              const Spacer(),
                              const _MiniSparkle(),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(child: hero),
                          const SizedBox(height: 30),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'myfont',
                              fontSize: 38,
                              height: 1.12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 16,
                              height: 1.65,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              _MetaChip(label: caption),
                              const _MetaChip(label: 'Tailored perfume access'),
                              const _MetaChip(label: 'Secure account layer'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _Reveal(
                        delay: 120,
                        child: form,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSectionTitle extends StatelessWidget {
  const AuthSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF15120D),
            fontFamily: 'myfont',
            fontSize: 27,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF4D443A).withValues(alpha: 0.92),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class AuthHelperCard extends StatelessWidget {
  const AuthHelperCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _Reveal(
      delay: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFF6EACC),
                  Color(0xFFF1DFC0),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE0C68E)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFD6B878).withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFFE7CC8E), Color(0xFFCBA35B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: const Color(0xFF18140F), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1B160F),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF5B4E40),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.screenGradient,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: _AuthAtmosphere()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _Reveal(
                    delay: 0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Color(0xFFF9F3E9),
                              Color(0xFFF2E9D8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: <Color>[Color(0xFFF0DEB4), Color(0xFFD2A95A)],
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(0xFFD6B878).withValues(alpha: 0.35),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: Icon(icon, size: 48, color: const Color(0xFF1B160F)),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF15120D),
                                fontFamily: 'myfont',
                                fontSize: 28,
                                height: 1.18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF5A4E40),
                                fontSize: 14,
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: onPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD6B878),
                                  foregroundColor: const Color(0xFF18140F),
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

BoxDecoration authHeroDecoration({double radius = 28}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xFF151413),
        Color(0xFF0C0B0A),
        Color(0xFF1B140C),
      ],
    ),
    border: Border.all(color: const Color(0xFF4A3820)),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.26),
        blurRadius: 34,
        offset: const Offset(0, 18),
      ),
    ],
  );
}

class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.child,
    required this.delay,
  });

  final Widget child;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 700 + delay),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? _) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 28),
            child: child,
          ),
        );
      },
    );
  }
}

class _AuthAtmosphere extends StatelessWidget {
  const _AuthAtmosphere();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -90,
          right: -20,
          child: _AmbientGlow(
            size: 260,
            color: const Color(0xFFD6B878).withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          top: 180,
          left: -60,
          child: _AmbientGlow(
            size: 220,
            color: const Color(0xFFA47A30).withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: -70,
          right: 20,
          child: _AmbientGlow(
            size: 220,
            color: const Color(0xFFD8B977).withValues(alpha: 0.10),
          ),
        ),
      ],
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _AuthBadge extends StatelessWidget {
  const _AuthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Get.locale?.languageCode == 'ar'
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFFF2D89C),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.86),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MiniSparkle extends StatelessWidget {
  const _MiniSparkle();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFD6B878).withValues(alpha: 0.12),
          border: Border.all(color: const Color(0xFF5D4725)),
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFFF2D89C),
          size: 17,
        ),
      ),
    );
  }
}
