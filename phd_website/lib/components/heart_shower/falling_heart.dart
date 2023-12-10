import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FallingHeart extends StatefulWidget {
  const FallingHeart({super.key});

  @override
  State<FallingHeart> createState() => _FallingHeartState();
}

class _FallingHeartState extends State<FallingHeart>
    with TickerProviderStateMixin {
  bool firstBuild = true;
  late AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final animationProps = _RandomAnimationProperties.random(
        windowWidth: constraints.maxWidth,
      );

      controller = AnimationController(
        duration: animationProps.fallingTime,
        vsync: this,
      );

      controller.addStatusListener((status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        controller.dispose();
        // Hack to make component rerender with new position and controller
        setState(() {});
      });

      if (firstBuild) {
        Future.delayed(animationProps.initialDelay)
            .then((value) => _beginAnimation());
        firstBuild = false;
      } else {
        _beginAnimation();
      }

      final animation =
          CurveTween(curve: Curves.easeInQuad).animate(controller);

      return AnimatedBuilder(
        animation: animation,
        child: const Icon(
          CupertinoIcons.heart_fill,
          color: Colors.red,
        ),
        builder: (context, child) {
          return Transform.scale(
            scale: animationProps.scale,
            child: Transform.translate(
              offset: Offset(
                animationProps.xOffset,
                constraints.maxHeight * (animation.value * 1.2 - 0.1),
              ),
              child: child,
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    if (!controller.isCompleted) {
      controller.dispose();
    }
    super.dispose();
  }

  void _beginAnimation() {
    if (mounted) {
      controller.forward();
    }
  }
}

class _RandomAnimationProperties {
  late final double xOffset;
  late final double scale;
  late final Duration fallingTime;
  late final Duration initialDelay;

  _RandomAnimationProperties.random({
    required double windowWidth,
  }) {
    final randomGenerator = Random();
    xOffset = randomGenerator.nextDouble() * windowWidth;
    fallingTime = Duration(
      milliseconds: (randomGenerator.nextDouble() * 2500 + 3500).toInt(),
    );
    initialDelay = Duration(
      milliseconds: (randomGenerator.nextDouble() * 4000).toInt(),
    );
    scale = randomGenerator.nextDouble() + 1;
  }
}
