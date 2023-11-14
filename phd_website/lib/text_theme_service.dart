import 'package:flutter/material.dart';

class TextThemeService {
  static TextStyle? getBodyTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (MediaQuery.of(context).size.width < 700) {
      return textTheme.bodyMedium;
    } else {
      return textTheme.bodyLarge;
    }
  }
}
