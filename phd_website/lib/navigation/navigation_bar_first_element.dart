import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:provider/provider.dart';

class NavigationBarFirstElement extends StatelessWidget {
  const NavigationBarFirstElement({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return ResponsiveLayout(
      desktopLayout: Padding(
        padding: const EdgeInsets.all(3.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerDown: (event) => context.go("/"),
            child: Image.asset(
              "images/wmat_logo.png",
              height: 60,
            ),
          ),
        ),
      ),
      mobileLayout: Padding(
        padding: const EdgeInsets.only(left: 20, top: 10),
        child: GestureDetector(
          onTap: () => globalState.changeMenuExpansion(),
          child: Icon(
            globalState.isMenuExpanded() ? Icons.close : Icons.menu_rounded,
            size: 35,
          ),
        ),
      ),
    );
  }
}
