import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phd_website/components/sweetie_easter_egg.dart';

import '../tester_extensions.dart';

void main() {
  testWidgets(
      'Given not started easter egg When "sweetie" is typed Then start animation',
      (tester) async {
    tester.initFullHDDesktop();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SweetieEasterEgg(
          child: Container(),
        ),
      ),
    ));

    final state =
        tester.state<SweetieEasterEggState>(find.byType(SweetieEasterEgg));

    expect(state.easterEggState, EasterEggState.notStarted);

    for (var char in 'sweetie'.characters) {
      var characterCode = char.codeUnitAt(0);
      var keyboardKey = LogicalKeyboardKey(characterCode);
      await tester.sendKeyEvent(keyboardKey);
    }
    await tester.pump();

    expect(state.easterEggState, EasterEggState.running);
  });

  testWidgets(
      'Given not started easter egg When gibberish is typed Then nothing happens',
      (tester) async {
    tester.initFullHDDesktop();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SweetieEasterEgg(
          child: Container(),
        ),
      ),
    ));

    for (var char in 'gibberishswee'.characters) {
      await tester.sendKeyEvent(LogicalKeyboardKey(char.codeUnitAt(0)));
    }
    await tester.pump();

    final state =
        tester.state<SweetieEasterEggState>(find.byType(SweetieEasterEgg));

    expect(state.easterEggState, EasterEggState.notStarted);
    expect(state.lettersPressed, 'swee');
  });

  testWidgets(
      'Given started easter egg When ESC is pressed Then popup disappears',
      (tester) async {
    tester.initFullHDDesktop();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SweetieEasterEgg(
          child: Container(),
        ),
      ),
    ));

    for (var char in 'sweetie'.characters) {
      await tester.sendKeyEvent(LogicalKeyboardKey(char.codeUnitAt(0)));
    }

    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    final state =
        tester.state<SweetieEasterEggState>(find.byType(SweetieEasterEgg));

    expect(state.easterEggState, EasterEggState.notStarted);
  });
}
