import 'dart:math';

class RandomAnimationProperties {
  static final Random _randomGenerator = Random();

  final double xOffset;
  final double scale;
  final double gForce;
  final Duration initialDelay;
  final double windowWidth;

  RandomAnimationProperties(
    this.xOffset,
    this.scale,
    this.gForce,
    this.initialDelay,
    this.windowWidth,
  );

  RandomAnimationProperties.random({
    required this.windowWidth,
  })  : xOffset = _randomGenerator.nextDouble() * windowWidth,
        gForce = _randomGenerator.nextDouble() * 40 + 100,
        initialDelay = Duration(
          milliseconds: (_randomGenerator.nextDouble() * 4000).toInt(),
        ),
        scale = _randomGenerator.nextDouble() + 1;

  RandomAnimationProperties resizeXOffset(double windowWidth) {
    return RandomAnimationProperties(
        _randomGenerator.nextDouble() * windowWidth,
        scale,
        gForce,
        initialDelay,
        windowWidth);
  }
}
