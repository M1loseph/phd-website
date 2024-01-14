import 'package:flutter/material.dart';
import 'package:phd_website/components/nav/language_switch.dart';
import 'package:phd_website/components/nav/menu_expansion_switch.dart';
import 'package:phd_website/components/nav/navigation_tabs.dart';
import 'package:phd_website/components/nav/wmat_logo.dart';
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
            const WMatLogo(),
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
            ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: globalState.isMenuExpanded() ? 200 : 0,
              color: globalState.isMenuExpanded()
                  ? Colors.white
                  : Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
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
                ],
              ),
            ),
          ),
          const MenuExpansionSwitch(),
        ],
      ),
    );
  }
}
