import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/components/footer.dart';
import 'package:phd_website/components/nav/side_navigation_bar.dart';
import 'package:phd_website/components/nav/top_navigation_bar.dart';
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
        mainAxisSize: MainAxisSize.max,
        children: [
          TopNavigationBar(currentPath: state.fullPath!),
          Expanded(
            child: currentPage,
          ),
          Footer()
        ],
      ),
      mobileLayout: SideNavigationBar(
        currentPath: state.fullPath!,
        currentPage: currentPage,
      ),
    );
  }
}
