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

  @override
  void initState() {
    super.initState();
    _recreateAnimationPropsAndAnimationController();
    Future.delayed(animationProps.initialDelay)
        .then((value) => _beginAnimation());
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

  void _recreateAnimationPropsAndAnimationController() {
    animationProps = RandomAnimationProperties.random(
      windowWidth: widget.constraints.maxWidth,
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
      setState(() {
        _recreateAnimationPropsAndAnimationController();
        _beginAnimation();
      });
    });
  }
}
