import 'package:flutter/material.dart';
import 'package:phd_website/components/platform_aware_image.dart';

class EasterEggPicture extends StatelessWidget {
  final int easterEggThreshold;
  final int currentValue;
  final String path;
  final String easterEggPath;

  const EasterEggPicture({
    super.key,
    required this.path,
    required this.easterEggPath,
    required this.easterEggThreshold,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedPath =
        currentValue % easterEggThreshold == 0 ? easterEggPath : path;
    return PlatformAwareImage(path: calculatedPath);
  }
}
