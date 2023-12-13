import 'dart:math';

class RandomAnimationProperties {
  static final Random _randomGenerator = Random();

  final double xOffset;
  final double scale;
  final Duration fallingTime;
  final Duration initialDelay;
  final double windowWidth;

  RandomAnimationProperties(
    this.xOffset,
    this.scale,
    this.fallingTime,
    this.initialDelay,
    this.windowWidth,
  );

  RandomAnimationProperties.random({
    required this.windowWidth,
  })  : xOffset = _randomGenerator.nextDouble() * windowWidth,
        fallingTime = Duration(
          milliseconds: (_randomGenerator.nextDouble() * 2500 + 3500).toInt(),
        ),
        initialDelay = Duration(
          milliseconds: (_randomGenerator.nextDouble() * 4000).toInt(),
        ),
        scale = _randomGenerator.nextDouble() + 1;

  RandomAnimationProperties resizeXOffset(double windowWidth) {
    return RandomAnimationProperties(
        _randomGenerator.nextDouble() * windowWidth,
        scale,
        fallingTime,
        initialDelay,
        windowWidth);
  }
}
