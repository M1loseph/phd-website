import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class MenuExpansionSwitch extends StatefulWidget {
  const MenuExpansionSwitch({super.key});

  @override
  State<MenuExpansionSwitch> createState() => _MenuExpansionSwitchState();
}

class _MenuExpansionSwitchState extends State<MenuExpansionSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    final animation = Tween(begin: 0.0, end: 1.0).animate(controller);

    if (globalState.isMenuExpanded()) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: GestureDetector(
        onTap: () {
          globalState.changeMenuExpansion();
        },
        child: AnimatedIcon(
          progress: animation,
          icon: AnimatedIcons.menu_close,
          size: 35,
        ),
      ),
    );
  }
}
