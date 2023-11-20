import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformAwareImage extends StatelessWidget {
  final String path;
  final double? height;

  const PlatformAwareImage({
    super.key,
    required this.path,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final String actualPath;
    if (kIsWeb && !kDebugMode) {
      actualPath = "assets/$path";
    } else {
      actualPath = path;
    }
    return Image.asset(
      actualPath,
      height: height,
    );
  }
}
