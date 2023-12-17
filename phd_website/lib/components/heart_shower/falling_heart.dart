import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'random_animation_properties.dart';

class FallingHeart extends StatefulWidget {
  final BoxConstraints constraints;

  const FallingHeart({super.key, required this.constraints});

  @override
  State<FallingHeart> createState() => _FallingHeartState();
}

class _FallingHeartState extends State<FallingHeart>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late RandomAnimationProperties animationProps;
  late Timer initialDelayTimer;

  @override
  void initState() {
    super.initState();
    _recreateAnimationProps();
    controller = AnimationController(
      duration: animationProps.fallingTime,
      vsync: this,
    )..addStatusListener((status) {
        if (status != AnimationStatus.completed) {
          return;
        }
        setState(() {
          _recreateAnimationProps();
          controller.reset();
          controller.duration = animationProps.fallingTime;
          _beginAnimation();
        });
      });

    initialDelayTimer = Timer(animationProps.initialDelay, _beginAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurveTween(curve: Curves.easeInQuad).animate(controller);

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
              widget.constraints.maxHeight * (animation.value * 1.2 - 0.1),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    initialDelayTimer.cancel();
    super.dispose();
  }

  void _beginAnimation() {
    if (!mounted) {
      return;
    }
    controller.forward();
  }

  void _recreateAnimationProps() {
    animationProps = RandomAnimationProperties.random(
      windowWidth: widget.constraints.maxWidth,
    );
  }
}
