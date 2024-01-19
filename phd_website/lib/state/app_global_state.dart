import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cookies_approval.dart';
import 'optional_feature.dart';

class AppGlobalState with ChangeNotifier {
  static const _v1_prefix = '_v1_';
  static const _langKey = '${_v1_prefix}lang';
  static const _cookiesAcknowledgedKey = '${_v1_prefix}cookiesAcknowledged';
  static const _siteEntriesKey = '${_v1_prefix}siteEntries';
  static const _siteEntriesInitialValue = 1;

  final Future<SharedPreferences> _sharedPref;
  String? _applicationTitle;
  bool _expandedMenu = false;

  AppGlobalState(this._sharedPref);

  void changeMenuExpansion() {
    _expandedMenu = !_expandedMenu;
    notifyListeners();
  }

  bool isMenuExpanded() => _expandedMenu;

  Future<Locale?> getCurrentLocale(BuildContext context) async {
    final sharedPref = await _sharedPref;
    final currentLocale = sharedPref.getString(_langKey);
    if (currentLocale == null) {
      if (!context.mounted) {
        return null;
      }
      return Localizations.localeOf(context);
    }
    return Locale(currentLocale);
  }

  String get applicationTitle => _applicationTitle ?? '';

  void changeApplicationTitle(String newTitle) {
    _applicationTitle = newTitle;
    notifyListeners();
  }

  Future<void> setCurrentLocale(String locale) async {
    final sharedPref = await _sharedPref;
    await sharedPref.setString(_langKey, locale);
    notifyListeners();
  }

  Future<void> acceptCookies() async {
    final sharedPref = await _sharedPref;
    await sharedPref.setString(
        _cookiesAcknowledgedKey, CookiesApproval.approved.name);
    notifyListeners();
  }

  Future<void> rejectCookies() async {
    final sharedPref = await _sharedPref;
    await sharedPref.setString(
        _cookiesAcknowledgedKey, CookiesApproval.rejected.name);
    notifyListeners();
  }

  Future<OptionalFeature<int>> getNumberOfEntires() async {
    final cookiesApprovalStatus = await getCookiesApprovalStatus();
    if (cookiesApprovalStatus != CookiesApproval.approved) {
      return OptionalFeature.disabled();
    }
    final sharedPref = await _sharedPref;
    final entries = sharedPref.getInt(_siteEntriesKey) ?? 1;
    return OptionalFeature.enabled(value: entries);
  }

  Future<void> bumpNumberOfEntires() async {
    final cookiesApprovalStatus = await getCookiesApprovalStatus();
    if (cookiesApprovalStatus != CookiesApproval.approved) {
      return;
    }
    final sharedPref = await _sharedPref;
    final entries =
        sharedPref.getInt(_siteEntriesKey) ?? _siteEntriesInitialValue;
    sharedPref.setInt(_siteEntriesKey, entries + 1);
    notifyListeners();
  }

  Future<CookiesApproval> getCookiesApprovalStatus() async {
    final sharedPref = await _sharedPref;
    final approvalStateString = sharedPref.getString(_cookiesAcknowledgedKey);
    if (approvalStateString == null) {
      return CookiesApproval.awaitingApproval;
    }
    return CookiesApproval.parseFromStringOrGetDefault(approvalStateString);
  }
}
