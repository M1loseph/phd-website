import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

enum _EasterEggState {
  notStarted,
  pending,
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
      Uri.parse("https://youtu.be/UTLFbVB8ctc?t=48");
  final magicLetterCombination = "sweetie";
  String lettersPressed = "";
  _EasterEggState easterEggState = _EasterEggState.notStarted;
  @override
  Widget build(BuildContext context) {
    if (easterEggState == _EasterEggState.pending) {
      setState(() {
        easterEggState = _EasterEggState.executing;
      });
      scheduleMicrotask(() async {
        await Future.delayed(Duration(seconds: 5));
        await launchUrl(magicEasterEggDestination);
        setState(() {
          easterEggState = _EasterEggState.notStarted;
        });
      });
    }
    return KeyboardListener(
      focusNode: FocusNode(onKey: handleKeyEvent),
      child: easterEggState == _EasterEggState.executing
          ? Stack(
              children: [
                widget,
                // TODO: create hears animation down here
              ],
            )
          : widget.child,
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
        lettersPressed = "";
      } else if (magicLetterCombination == lettersPressed) {
        lettersPressed = "";
        easterEggState = _EasterEggState.pending;
      }
    });
    return KeyEventResult.handled;
  }
}
