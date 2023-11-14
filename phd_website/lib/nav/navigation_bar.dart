import 'package:flutter/material.dart';
import 'package:phd_website/nav/language_switch.dart';
import 'package:phd_website/nav/navigation_tabs.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/nav/navigation_bar_first_element.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
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
      mobileLayout: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topLeft,
        child: Container(
          color:
              globalState.isMenuExpanded() ? appBarColor : Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NavigationBarFirstElement(),
              globalState.isMenuExpanded()
                  ? NavigationTabs(
                      currentPath: currentPath,
                    )
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
