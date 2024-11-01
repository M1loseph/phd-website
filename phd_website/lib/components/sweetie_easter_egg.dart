import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phd_website/components/adapters/testable_web_view_adapter.dart';
import 'package:phd_website/components/heart_shower/heart_shower.dart';
import 'package:phd_website/logger/logger.dart';

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
  static const closeButtonSize = 40.0;
  static const playerSize = Size(640, 360);
  static const magicEasterEggDestination =
      'https://youtube.com/embed/UTLFbVB8ctc?start=48';
  static const magicLetterCombination = 'sweetie';

  final Logger logger = Logger(SweetieEasterEggState);
  late final FocusNode sweetieKeyboardFocusNode;
  late final FocusNode escapeFocusNode;

  String lettersPressed = '';
  EasterEggState easterEggState = EasterEggState.notStarted;

  @override
  void initState() {
    super.initState();
    sweetieKeyboardFocusNode = FocusNode()..requestFocus();
    escapeFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: sweetieKeyboardFocusNode,
      onKeyEvent: handleMagicCombinationEvent,
      child: Stack(
        children: [
          widget.child,
          if (easterEggState == EasterEggState.running)
            KeyboardListener(
              focusNode: escapeFocusNode,
              onKeyEvent: handleDesiredEscapeEvent,
              child: Container(
                color: Colors.black.withAlpha(100),
                child: Stack(
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: playerSize.height + closeButtonSize * 2.5,
                          maxWidth: playerSize.width + closeButtonSize * 2.5,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Material(
                            color: Colors.transparent,
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Colors.grey.shade800,
                                shape: const CircleBorder(),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                iconSize: closeButtonSize,
                                onPressed: closePopup,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: playerSize.height,
                          maxWidth: playerSize.width,
                        ),
                        child: const TestableWebViewAdapter(
                          destination: magicEasterEggDestination,
                        ),
                      ),
                    ),
                  ],
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

  KeyEventResult handleMagicCombinationEvent(KeyEvent event) {
    if (kDebugMode) {
      logger.debug('magic combination => event ${event.runtimeType} ${event.logicalKey.debugName}');
    }
    if (easterEggState == EasterEggState.running) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    final character = event.character;
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

  KeyEventResult handleDesiredEscapeEvent(KeyEvent event) {
    if (kDebugMode) {
      logger.debug('escape listener => event ${event.runtimeType} ${event.logicalKey.debugName}');
    }
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      closePopup();
    }
    return KeyEventResult.handled;
  }
}

@visibleForTesting
enum EasterEggState {
  notStarted,
  running,
}
