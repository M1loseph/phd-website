import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/constants.dart';

// For some magical reason I could not get the class solution to work.
// Every time I create the class that acts as a wrapper that delegates
// all possible calls to the delegate property, some assertions fail.
responsiveTransitionPage<T>({
  LocalKey? key,
  required Widget child,
  required BuildContext context,
}) {
  final width = MediaQuery.of(context).size.width;

  if (isMobileView(width)) {
    return CustomTransitionPage<T>(
      key: key,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
          child: child,
        );
      },
      child: child,
    );
  } else {
    return NoTransitionPage<T>(
      key: key,
      child: child,
    );
  }
}
