import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class PlatformAwareWidget extends StatelessWidget {
  const PlatformAwareWidget({super.key});

  @protected
  String getActualPath(String path) {
    if (kIsWeb && !kDebugMode) {
      return "assets/$path";
    } else {
      return path;
    }
  }
}
