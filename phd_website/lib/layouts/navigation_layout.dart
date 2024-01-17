import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/components/nav/navigation_bar.dart' as navbar;
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class NavigationLayout extends StatelessWidget {
  final GoRouterState state;
  final Widget currentPage;

  const NavigationLayout({
    super.key,
    required this.state,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<AppGlobalState>();
    return ResponsiveLayout(
      desktopLayout: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: currentPage,
              ),
            ],
          ),
          navbar.NavigationBar(currentPath: state.fullPath!),
        ],
      ),
      mobileLayout: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 0) {
                globalState.changeMenuExpansion();
              }
            },
            child: currentPage,
          ),
          navbar.NavigationBar(currentPath: state.fullPath!)
        ],
      ),
    );
  }
}
