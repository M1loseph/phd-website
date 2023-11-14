import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/nav/navigation_bar.dart' as navbar;

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
    final nav = navbar.NavigationBar(currentPath: state.fullPath!);
    return ResponsiveLayout(
      desktopLayout: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nav,
          Expanded(
            child: PageLayout(
              page: currentPage,
            ),
          ),
        ],
      ),
      mobileLayout: Stack(
        children: [
          PageLayout(
            page: currentPage,
          ),
          nav,
        ],
      ),
    );
  }
}
