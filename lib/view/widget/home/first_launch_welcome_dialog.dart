import 'package:flutter/material.dart';

class FirstLaunchWelcomeDialog extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onFinish;

  const FirstLaunchWelcomeDialog({
    super.key,
    required this.isArabic,
    required this.onFinish,
  });

  @override
  State<FirstLaunchWelcomeDialog> createState() =>
      _FirstLaunchWelcomeDialogState();
}

class _FirstLaunchWelcomeDialogState extends State<FirstLaunchWelcomeDialog> {
  late final PageController _pageController;
  int _currentPage = 0;

  late final List<_WelcomeCardData> _pages = <_WelcomeCardData>[
    _WelcomeCardData(
      badge: widget.isArabic ? 'مرحبا بك' : 'Welcome',
      title: widget.isArabic
          ? 'كل ما تحتاجه من العطور في مكان واحد'
          : 'Everything fragrance-related in one place',
      body: widget.isArabic
          ? 'تصفح العطور بسهولة، واكتشف التفاصيل والنوتات داخل تجربة أنيقة ومريحة من أول لحظة.'
          : 'Browse fragrances easily, explore notes and details, and enjoy a premium experience from the first tap.',
      icon: Icons.auto_awesome_rounded,
    ),
    _WelcomeCardData(
      badge: widget.isArabic ? 'اختيار ذكي' : 'Smart Choice',
      title: widget.isArabic
          ? 'اختر العطر المناسب حسب ذوقك ومزاجك'
          : 'Choose the right fragrance for your taste and mood',
      body: widget.isArabic
          ? 'راجع العائلة العطرية، الحجم، والسعر، ثم اختر الزجاجة التي تناسبك بثقة ووضوح.'
          : 'Review the fragrance family, size, and price, then choose the bottle that suits you with confidence.',
      icon: Icons.diamond_outlined,
    ),
    _WelcomeCardData(
      badge: widget.isArabic ? 'بعد الطلب' : 'After Checkout',
      title: widget.isArabic
          ? 'تابع طلباتك واستفد من الدعم والعروض'
          : 'Track orders and enjoy support and offers',
      body: widget.isArabic
          ? 'من السلة وحتى متابعة الطلب، كل خطوة واضحة وسلسة داخل التطبيق مع تجربة مناسبة لعالم العطور.'
          : 'From cart to order tracking, every step stays clear, elegant, and easy to follow inside the app.',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLast = _currentPage == _pages.length - 1;
    const Color gold = Color(0xFFD6B878);
    const Color goldSoft = Color(0xFFE9D7AA);
    const Color panel = Color(0xFF11100E);
    const Color panelSoft = Color(0xFF1A1815);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF2E261B)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.48),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: gold.withValues(alpha: 0.08),
              blurRadius: 34,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: panelSoft,
                  border: Border.all(color: const Color(0xFF413523)),
                ),
                child: IconButton(
                  onPressed: widget.onFinish,
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final _WelcomeCardData page = _pages[index];
                  return Column(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: <Color>[
                                  gold.withValues(alpha: 0.18),
                                  gold.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0xFF332E27),
                                  Color(0xFF1A1713),
                                ],
                              ),
                              border: Border.all(color: const Color(0xFF5A4C35)),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.14),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Icon(page.icon, color: goldSoft, size: 38),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: panelSoft,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF3B3125)),
                        ),
                        child: Text(
                          page.badge,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: goldSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: 25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.76),
                            height: 1.7,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _pages.length,
                (int index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? gold
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: widget.onFinish,
                    child: Text(
                      widget.isArabic ? 'تخطي' : 'Skip',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        widget.onFinish();
                        return;
                      }
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: const Color(0xFF16120D),
                      minimumSize: const Size.fromHeight(54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isLast
                          ? (widget.isArabic ? 'ابدأ الآن' : 'Start now')
                          : (widget.isArabic ? 'التالي' : 'Next'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCardData {
  final String badge;
  final String title;
  final String body;
  final IconData icon;

  const _WelcomeCardData({
    required this.badge,
    required this.title,
    required this.body,
    required this.icon,
  });
}
