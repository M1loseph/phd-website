import 'package:flutter/material.dart';

const mobileMaxWidth = 900;

bool _isMobileView(double width) {
  return width < mobileMaxWidth;
}

bool isMobileView(BuildContext context) {
  return _isMobileView(MediaQuery.of(context).size.width);
}
