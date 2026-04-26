import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/home/homescreen_controller.dart';
import 'package:tks/core/theme/app_surface_palette.dart';

class CustomBottomAppBarHome extends StatelessWidget {
  const CustomBottomAppBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return GetBuilder<HomeScreenControllerImp>(
      builder: (HomeScreenControllerImp controller) {
        return SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            height: 78,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: List<Widget>.generate(controller.bottomappbar.length,
                  (int index) {
                final bool isActive = controller.currentpage == index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => controller.changePage(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isActive
                            ? palette.accent.withValues(alpha: 0.14)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isActive ? palette.accent : palette.cardAlt,
                            ),
                            child: Icon(
                              controller.bottomappbar[index]['icon']
                                  as IconData,
                              size: 19,
                              color: isActive
                                  ? palette.accentText
                                  : palette.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Flexible(
                            child: Text(
                              (controller.bottomappbar[index]['title']
                                      as String)
                                  .tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive
                                    ? palette.accent
                                    : palette.tertiaryText,
                                fontWeight: isActive
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: 10,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
