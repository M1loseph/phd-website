import 'package:flutter/material.dart';
import 'package:phd_website/constants.dart';

class BodyTextStyleService {
  TextStyle? getBodyTextStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (MediaQuery.of(context).size.width < mobileMaxWidth) {
      return textTheme.bodyMedium;
    } else {
      return textTheme.bodyLarge;
    }
  }
}
