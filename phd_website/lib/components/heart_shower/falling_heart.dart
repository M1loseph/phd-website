import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phd_website/components/heart_shower/random_animation_properties.dart';

class FallingHeart extends StatefulWidget {
  final BoxConstraints constraints;

  const FallingHeart({super.key, required this.constraints});

  @override
  State<FallingHeart> createState() => _FallingHeartState();
}

// SingleTickerProvider is more efficient than TickerProviderStateMixin
// https://stackoverflow.com/questions/73861656/difference-between-tickerproviderstatemixin-and-singletickerproviderstatemixin
class _FallingHeartState extends State<FallingHeart>
    with SingleTickerProviderStateMixin {
  // TODO: make it dynamic
  static const _heartSize = 40.0;
  late final AnimationController controller;
  late RandomAnimationProperties animationProps;
  Timer? tasksTimer;

  Offset manualUpdateOffset = Offset.zero;
  Offset inertia = Offset.zero;

  @override
  void initState() {
    super.initState();
    _recreateAnimationProps();
    controller = AnimationController(
      duration: const Duration(minutes: 1),
      vsync: this,
    );
    tasksTimer = Timer(animationProps.initialDelay, _beginAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final dt = Tween(
      begin: 0.0,
      end: 60.0,
    ).animate(controller);

    return AnimatedBuilder(
      animation: controller,
      child: GestureDetector(
        onPanDown: (details) {
          setState(() {
            controller.stop();
            controller.reset();
            manualUpdateOffset = Offset(
              details.globalPosition.dx - _heartSize / 2 * animationProps.scale,
              details.globalPosition.dy -
                  _heartSize / 2 * animationProps.scale +
                  beginOffset(),
            );
          });
        },
        onPanUpdate: (details) {
          setState(() {
            inertia = details.delta;
            manualUpdateOffset += details.delta;
          });
        },
        onPanEnd: (_) {
          inertia *= 10;
          controller.forward();
        },
        child: Icon(
          CupertinoIcons.heart_fill,
          color: Colors.red,
          size: _heartSize * animationProps.scale,
        ),
      ),
      builder: (context, child) {
        final (dx, dy) = _calculateOffset(dt.value);
        if (_heartFellOffTheScreen(dy)) {
          _reinitializeAnimationUsingTimer();
        }
        return Positioned(
          top: dy,
          left: dx,
          child: child!,
        );
      },
    );
  }

  (double, double) _calculateOffset(double t) {
    final double dy;
    final double dx;
    if (controller.isAnimating) {
      final y0 = manualUpdateOffset.dy;
      final v0 = inertia.dy;
      final g = animationProps.gForce;
      dy = y0 + (t * t * g / 2) + t * v0;

      final x0 = manualUpdateOffset.dx != 0
          ? manualUpdateOffset.dx
          : animationProps.xOffset;
      dx = x0 + inertia.dx * t;
    } else {
      dy = manualUpdateOffset.dy;
      dx = manualUpdateOffset.dx;
    }
    return (dx, dy - beginOffset());
  }

  double beginOffset() => widget.constraints.maxHeight * 0.1;

  @override
  void dispose() {
    controller.dispose();
    tasksTimer?.cancel();
    super.dispose();
  }

  void _beginAnimation() {
    if (!mounted) {
      return;
    }
    controller.forward();
  }

  void _reinitializeAnimationUsingTimer() {
    tasksTimer?.cancel();
    tasksTimer = Timer(const Duration(seconds: 0), _reinitializeAnimation);
  }

  void _reinitializeAnimation() {
    setState(() {
      manualUpdateOffset = Offset.zero;
      inertia = Offset.zero;
      _recreateAnimationProps();
      controller.reset();
      _beginAnimation();
    });
  }

  bool _heartFellOffTheScreen(double dy) {
    return dy >
        widget.constraints.maxHeight + _heartSize * animationProps.scale;
  }

  void _recreateAnimationProps() {
    animationProps = RandomAnimationProperties.random(
      windowWidth: widget.constraints.maxWidth,
    );
  }
}
