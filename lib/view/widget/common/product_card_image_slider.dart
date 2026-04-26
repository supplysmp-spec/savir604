import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class ProductCardImageSlider extends StatefulWidget {
  final List<String> imagePaths;
  final String? label;
  final double borderRadius;
  final bool showDots;
  final BoxFit fit;
  final EdgeInsetsGeometry imagePadding;
  final Widget? topLeft;
  final Widget? topRight;
  final Widget? bottomOverlay;

  const ProductCardImageSlider({
    super.key,
    required this.imagePaths,
    this.label,
    this.borderRadius = 22,
    this.showDots = true,
    this.fit = BoxFit.contain,
    this.imagePadding = const EdgeInsets.fromLTRB(10, 8, 10, 16),
    this.topLeft,
    this.topRight,
    this.bottomOverlay,
  });

  @override
  State<ProductCardImageSlider> createState() => _ProductCardImageSliderState();
}

class _ProductCardImageSliderState extends State<ProductCardImageSlider> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  List<String> get _images =>
      widget.imagePaths.where((e) => e.trim().isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _configureTimer();
  }

  @override
  void didUpdateWidget(covariant ProductCardImageSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePaths.join('||') != widget.imagePaths.join('||')) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _configureTimer();
    }
  }

  void _configureTimer() {
    _timer?.cancel();
    if (_images.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextIndex = (_currentIndex + 1) % _images.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMany = _images.length > 1;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: 0.92,
              heightFactor: 0.90,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.borderRadius),
                  topRight: Radius.circular(widget.borderRadius),
                  bottomLeft: Radius.circular(widget.borderRadius + 12),
                  bottomRight: Radius.circular(widget.borderRadius + 12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111111)
                        : Colors.white.withValues(alpha: 0.96),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: widget.imagePadding,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _images.isEmpty ? 1 : _images.length,
                      onPageChanged: (index) {
                        if (mounted) {
                          setState(() => _currentIndex = index);
                        }
                      },
                      itemBuilder: (context, index) {
                        final imagePath = _images.isEmpty
                            ? ''
                            : _images[index.clamp(0, _images.length - 1)];
                        return Center(
                          child: FallbackNetworkImage(
                            imageUrls: AppImageUrls.item(imagePath),
                            label: widget.label,
                            fit: widget.fit,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.topLeft != null)
          Positioned(
            top: 10,
            left: 10,
            child: widget.topLeft!,
          ),
        if (widget.topRight != null)
          Positioned(
            top: 10,
            right: 10,
            child: widget.topRight!,
          ),
        if (widget.bottomOverlay != null)
          Positioned(
            right: 10,
            left: 10,
            bottom: hasMany && widget.showDots ? 58 : 10,
            child: widget.bottomOverlay!,
          ),
        if (hasMany && widget.showDots)
          Positioned(
            left: 18,
            right: 18,
            bottom: 30,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _images.length,
                    (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF111111)
                              : Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
