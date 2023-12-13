import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterScreenSizeExtension on WidgetTester {
  void initFullHDDesktop() {
    view.physicalSize = const Size(1920, 1080);
    view.devicePixelRatio = 1.0;
  }
}
