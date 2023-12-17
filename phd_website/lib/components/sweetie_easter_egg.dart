import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phd_website/components/adapters/testable_web_view_adapter.dart';
import 'package:phd_website/components/heart_shower/heart_shower.dart';

class SweetieEasterEgg extends StatefulWidget {
  final Widget child;

  const SweetieEasterEgg({
    super.key,
    required this.child,
  });

  @override
  State<SweetieEasterEgg> createState() => SweetieEasterEggState();
}

@visibleForTesting
class SweetieEasterEggState extends State<SweetieEasterEgg> {
  static const magicEasterEggDestination =
      'https://youtube.com/embed/UTLFbVB8ctc?start=48';
  final magicLetterCombination = 'sweetie';

  String lettersPressed = '';
  EasterEggState easterEggState = EasterEggState.notStarted;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(onKey: handleKeyEvent)..requestFocus(),
      child: Stack(
        children: [
          widget.child,
          if (easterEggState == EasterEggState.running)
            GestureDetector(
              onTap: () {
                setState(() {
                  easterEggState = EasterEggState.notStarted;
                });
              },
              child: Container(
                color: Colors.black.withAlpha(100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 360,
                      maxWidth: 640,
                    ),
                    child: const TestableWebViewAdapter(
                        destination: magicEasterEggDestination),
                  ),
                ),
              ),
            ),
          if (easterEggState == EasterEggState.running) const HeartShower(),
        ],
      ),
    );
  }

  KeyEventResult handleKeyEvent(node, event) {
    if (easterEggState != EasterEggState.notStarted) {
      return KeyEventResult.ignored;
    }
    if (event is! RawKeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final castedEvent = event;
    final character = castedEvent.character;
    if (character == null) {
      return KeyEventResult.ignored;
    }
    setState(() {
      lettersPressed += character;
      if (!magicLetterCombination.startsWith(lettersPressed)) {
        lettersPressed = character;
      } else if (magicLetterCombination == lettersPressed) {
        lettersPressed = '';
        easterEggState = EasterEggState.running;
      }
    });
    return KeyEventResult.handled;
  }
}

@visibleForTesting
enum EasterEggState {
  notStarted,
  running,
}
