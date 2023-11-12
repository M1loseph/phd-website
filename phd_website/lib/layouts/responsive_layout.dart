import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final _mobileViewMaxWidth = 850;
  final Widget _desktopLayout;
  final Widget _mobileLayout;

  const ResponsiveLayout(
      {super.key, required Widget desktopLayout, required Widget mobileLayout})
      : _mobileLayout = mobileLayout,
        _desktopLayout = desktopLayout;

  @override
  Widget build(BuildContext context) {
    if (_isMobileView(context)) {
      return _mobileLayout;
    } else {
      return _desktopLayout;
    }
  }

  bool _isMobileView(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < _mobileViewMaxWidth;
  }
}
