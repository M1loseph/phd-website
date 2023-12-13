import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phd_website/components/nav/language_switch.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../tester_extensions.dart';

void main() {
  testWidgets(
      'Given full screen When language is selected Then appropriate button should be highlighted',
      (tester) async {
    tester.initFullHDDesktop();
    SharedPreferences.setMockInitialValues({});
    final globalState = AppGlobalState(SharedPreferences.getInstance());

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => globalState,
        child: const MaterialApp(
          home: Scaffold(
            body: LanguageSwitch(),
          ),
        ),
      ),
    );

    await globalState.setCurrentLocale('pl');
    await tester.pumpAndSettle();

    final plButtonFinder = find.byKey(const Key('pl-button'));
    final enButtonFinder = find.byKey(const Key('en-button'));
    final plButton = plButtonFinder.evaluate().single.widget as LanguageButton;
    final enButton = enButtonFinder.evaluate().single.widget as LanguageButton;

    expect(plButtonFinder, findsOne,
        reason: 'There should be one polish language button');
    expect(enButtonFinder, findsOne,
        reason: 'There should be one english language button');
    expect(plButton.isActive(), true,
        reason: 'Polish language button should be active');
    expect(enButton.isActive(), false,
        reason: 'English language button should not be active');
  });
}
