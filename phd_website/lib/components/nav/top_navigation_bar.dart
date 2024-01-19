import 'package:flutter/material.dart';
import 'package:phd_website/components/nav/language_switch.dart';
import 'package:phd_website/components/nav/navigation_tabs.dart';
import 'package:phd_website/components/nav/wmat_logo.dart';

class TopNavigationBar extends StatelessWidget {
  final String currentPath;

  const TopNavigationBar({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor;
    return Container(
      decoration: BoxDecoration(
        color: appBarColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          const WMatLogo(),
          NavigationTabs(
            currentPath: currentPath,
          ),
          const LanguageSwitch(),
        ],
      ),
    );
  }
}
