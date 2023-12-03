import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class HeartShower extends StatefulWidget {
  const HeartShower({
    super.key,
  });

  @override
  State<HeartShower> createState() => _HeartShowerState();
}

class _HeartShowerState extends State<HeartShower>
    with TickerProviderStateMixin {
  late final controller = AnimationController(
    duration: const Duration(seconds: 6),
    vsync: this,
  )..repeat();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final positions = [
          for (int i = 0; i < 100; i++)
            _OffsetAndDuration.random(
              windowHeight: constraints.maxHeight,
              windowWidth: constraints.maxWidth,
            ),
        ];
        final animation =
            CurveTween(curve: Curves.easeInQuad).animate(controller);
        return AnimatedBuilder(
          animation: animation,
          child: const Icon(
            CupertinoIcons.heart_fill,
            color: Colors.red,
          ),
          builder: (context, child) {
            return Stack(
              children: [
                for (final position in positions)
                  Transform.scale(
                    scale: position.scale,
                    child: Transform.translate(
                      offset: Offset(
                        position.xOffset,
                        position.yOffset * animation.value,
                      ),
                      child: child,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _OffsetAndDuration {
  late final double xOffset;
  late final double yOffset;
  late final double scale;

  _OffsetAndDuration.random({
    required double windowHeight,
    required double windowWidth,
  }) {
    final randomGenerator = Random();
    xOffset = randomGenerator.nextDouble() * windowWidth;
    yOffset = randomGenerator.nextDouble() * windowHeight * 2;
    scale = randomGenerator.nextDouble() + 1;
  }
}
