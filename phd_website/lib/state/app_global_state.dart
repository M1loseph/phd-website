import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cookies_approval.dart';
import 'optional_feature.dart';

class AppGlobalState with ChangeNotifier {
  final _langKey = "lang";
  final _cookiesAcknowledgedKey = "cookiesAcknowledged";
  final _siteEntriesKey = "siteEntires";

  bool _expandedMenu = false;

  AppGlobalState() {
    bumpNumberOfEntires();
  }

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

  void acceptCookies() async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString(
        _cookiesAcknowledgedKey, CookiesApproval.approved.name);
    notifyListeners();
  }

  void rejectCookies() async {
    final sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setBool(_cookiesAcknowledgedKey, false);
    notifyListeners();
  }

  Future<OptionalFeature<int>> getNumberOfEntires() async {
    final cookiesApprovalStatus = await getCookiesApprovalStatus();
    if (cookiesApprovalStatus != CookiesApproval.approved) {
      return OptionalFeature.disabled();
    }
    final sharedPref = await SharedPreferences.getInstance();
    final entries = sharedPref.getInt(_siteEntriesKey) ?? 1;
    return OptionalFeature.enabled(value: entries);
  }

  void bumpNumberOfEntires() async {
    final cookiesApprovalStatus = await getCookiesApprovalStatus();
    if (cookiesApprovalStatus != CookiesApproval.approved) {
      return;
    }
    final sharedPref = await SharedPreferences.getInstance();
    final entries = sharedPref.getInt(_siteEntriesKey) ?? 0;
    sharedPref.setInt(_siteEntriesKey, entries + 1);
    notifyListeners();
  }

  Future<CookiesApproval> getCookiesApprovalStatus() async {
    final sharedPref = await SharedPreferences.getInstance();
    final approvalStateString = sharedPref.getString(_cookiesAcknowledgedKey);
    if (approvalStateString == null) {
      return CookiesApproval.awaitingApproval;
    }
    return CookiesApproval.values.byName(approvalStateString);
  }
}
