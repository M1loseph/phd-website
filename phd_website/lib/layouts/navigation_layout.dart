import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/components/nav/navigation_bar.dart' as navbar;
import 'package:phd_website/layouts/responsive_layout.dart';

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
    return ResponsiveLayout(
      desktopLayout: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          navbar.NavigationBar(currentPath: state.fullPath!),
          Expanded(
            child: currentPage,
          ),
        ],
      ),
      mobileLayout: Stack(
        children: [
          currentPage,
          navbar.NavigationBar(currentPath: state.fullPath!)
        ],
      ),
    );
  }
}
