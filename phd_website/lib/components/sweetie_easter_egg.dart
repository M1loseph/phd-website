import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phd_website/components/heart_shower.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum _EasterEggState {
  notStarted,
  executing,
}

class SweetieEasterEgg extends StatefulWidget {
  final Widget child;

  const SweetieEasterEgg({
    super.key,
    required this.child,
  });

  @override
  State<SweetieEasterEgg> createState() => _SweetieEasterEggState();
}

class _SweetieEasterEggState extends State<SweetieEasterEgg> {
  final magicEasterEggDestination =
      Uri.parse("https://youtube.com/embed/UTLFbVB8ctc?start=48");
  late final controller = WebViewController()
    ..loadRequest(magicEasterEggDestination);
  final magicLetterCombination = "sweetie";

  String lettersPressed = "";
  _EasterEggState easterEggState = _EasterEggState.notStarted;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(onKey: handleKeyEvent),
      child: Stack(
        children: [
          widget.child,
          if (easterEggState == _EasterEggState.executing)
            GestureDetector(
              onTap: () {
                setState(() {
                  easterEggState = _EasterEggState.notStarted;
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
                    child: WebViewWidget(controller: controller),
                  ),
                ),
              ),
            ),
          if (easterEggState == _EasterEggState.executing) const HeartShower(),
        ],
      ),
    );
  }

  KeyEventResult handleKeyEvent(node, event) {
    if (easterEggState != _EasterEggState.notStarted) {
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
        lettersPressed = "";
        easterEggState = _EasterEggState.executing;
      }
    });
    return KeyEventResult.handled;
  }
}
