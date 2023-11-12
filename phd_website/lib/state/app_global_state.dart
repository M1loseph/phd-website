import 'package:flutter/material.dart';

class AppGlobalState with ChangeNotifier {
  bool _expandedMenu = false;
  final BuildContext context;

  AppGlobalState(this.context);

  void changeMenuExpansion() {
    _expandedMenu = !_expandedMenu;
    notifyListeners();
  }

  bool isMenuExpanded() {
    return _expandedMenu;
  }

  TextStyle? getMainContextTextStyle() {
    final textTheme = Theme.of(context).textTheme;
    if (MediaQuery.of(context).size.width < 700) {
      return textTheme.bodyMedium;
    } else {
      return textTheme.bodyLarge;
    }
  }
}
