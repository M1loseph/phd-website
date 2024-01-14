import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class MenuExpansionSwitch extends StatelessWidget {
  const MenuExpansionSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: GestureDetector(
        onTap: () => globalState.changeMenuExpansion(),
        child: Icon(
          globalState.isMenuExpanded() ? Icons.close : Icons.menu_rounded,
          size: 35,
        ),
      ),
    );
  }
}
