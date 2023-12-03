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
  late final controller =
      AnimationController(duration: Duration(seconds: 6), vsync: this)
        ..repeat();

  final positions = [
    for (int i = 0; i < 100; i++) _OffsetAndDuration.random(),
  ];

  @override
  Widget build(BuildContext context) {
    final animation = Tween(begin: 0.0, end: 1.0).animate(controller);
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
                    position.height * animation.value,
                  ),
                  child: child,
                ),
              ),
          ],
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
  late final double height;
  late final double scale;

  _OffsetAndDuration.random() {
    final randomGenerator = Random();
    xOffset = randomGenerator.nextDouble() * 2000;
    height = randomGenerator.nextDouble() * 4000;
    scale = randomGenerator.nextDouble() + 1;
  }
}
