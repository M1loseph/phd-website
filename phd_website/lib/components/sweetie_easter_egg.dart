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
  late final FocusNode sweetieKeyboardFocusNode;
  late final FocusNode escapeFocusNode;

  String lettersPressed = '';
  EasterEggState easterEggState = EasterEggState.notStarted;

  @override
  void initState() {
    super.initState();
    sweetieKeyboardFocusNode = FocusNode(onKey: handleMagicCombinationEvent)
      ..requestFocus();
    escapeFocusNode = FocusNode(onKey: handleDesiredEscapeEvent);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: sweetieKeyboardFocusNode,
      child: Stack(
        children: [
          widget.child,
          if (easterEggState == EasterEggState.running)
            KeyboardListener(
              focusNode: escapeFocusNode,
              child: GestureDetector(
                onTap: closePopup,
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
            ),
          if (easterEggState == EasterEggState.running) const HeartShower(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    sweetieKeyboardFocusNode.dispose();
    escapeFocusNode.dispose();
    super.dispose();
  }

  void closePopup() {
    setState(() {
      easterEggState = EasterEggState.notStarted;
    });
  }

  KeyEventResult handleMagicCombinationEvent(node, event) {
    if (easterEggState == EasterEggState.running) {
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
        escapeFocusNode.requestFocus();
      }
    });
    return KeyEventResult.handled;
  }

  KeyEventResult handleDesiredEscapeEvent(node, event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      closePopup();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

@visibleForTesting
enum EasterEggState {
  notStarted,
  running,
}
