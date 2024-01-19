import 'package:flutter/material.dart';
import 'package:phd_website/components/nav/language_switch.dart';
import 'package:phd_website/components/nav/menu_expansion_switch.dart';
import 'package:phd_website/components/nav/navigation_tabs.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class SideNavigationBar extends StatelessWidget {
  final String currentPath;
  final Widget currentPage;

  const SideNavigationBar({
    super.key,
    required this.currentPath,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return Stack(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.deferToChild,
            onHorizontalDragEnd: (details) {
              final dx = details.velocity.pixelsPerSecond.dx;
              if (!globalState.isMenuExpanded() && dx > 0) {
                globalState.changeMenuExpansion();
              }
            },
            child: currentPage,
          ),
        ),
        if (globalState.isMenuExpanded())
          GestureDetector(
            onTap: () {
              if (globalState.isMenuExpanded()) {
                globalState.changeMenuExpansion();
              }
            },
            onHorizontalDragEnd: (details) {
              final dx = details.velocity.pixelsPerSecond.dx;
              if (globalState.isMenuExpanded() && dx < 0) {
                globalState.changeMenuExpansion();
              }
            },
            child: Container(
              color: Colors.grey.shade500.withAlpha(100),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: globalState.isMenuExpanded() ? 200 : 0,
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                )
              ],
              color: globalState.isMenuExpanded()
                  ? Colors.white
                  : Colors.transparent,
            ),
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
    );
  }
}
