import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppGlobalState with ChangeNotifier {
  final _langKey = "lang";

  bool _expandedMenu = false;

  AppGlobalState();

  void changeMenuExpansion() {
    _expandedMenu = !_expandedMenu;
    notifyListeners();
  }

  bool isMenuExpanded() {
    return _expandedMenu;
  }

  Future<Locale?> getCurrentLocale(BuildContext context) async {
    final sharedPref = await SharedPreferences.getInstance();
    final currentLocale = sharedPref.getString(_langKey);
    if (currentLocale == null) {
      if (!context.mounted) {
        return null;
      }
      return Localizations.localeOf(context);
    }
    return Locale(currentLocale);
  }

  void setCurrentLocale(String locale) async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(_langKey, locale);
    notifyListeners();
  }
}
