import 'package:flutter/material.dart';
import 'package:phd_website/components/nav/language_switch.dart';
import 'package:phd_website/components/nav/navigation_bar_first_element.dart';
import 'package:phd_website/components/nav/navigation_tabs.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class NavigationBar extends StatelessWidget {
  final String currentPath;

  const NavigationBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    return ResponsiveLayout(
      desktopLayout: Container(
        color: appBarColor,
        child: Row(
          children: [
            const NavigationBarFirstElement(),
            NavigationTabs(
              currentPath: currentPath,
            ),
            const LanguageSwitch(),
          ],
        ),
      ),
      mobileLayout: Stack(
        children: [
          if (globalState.isMenuExpanded())
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => globalState.changeMenuExpansion(),
                child: Container(
                  color: Colors.grey.shade500.withAlpha(100),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topLeft,
            child: Container(
              color: globalState.isMenuExpanded()
                  ? Colors.white
                  : Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NavigationBarFirstElement(),
                  if (globalState.isMenuExpanded())
                    Expanded(
                      child: Column(
                        children: [
                          NavigationTabs(
                            currentPath: currentPath,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const LanguageSwitch()
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
