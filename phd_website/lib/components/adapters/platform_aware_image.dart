import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformAwareImage extends StatelessWidget {
  const PlatformAwareImage({super.key});

  @protected
  String getActualPath(String path) {
    if (kIsWeb && !kDebugMode) {
      return 'assets/$path';
    } else {
      return path;
    }
  }
}
