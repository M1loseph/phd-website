import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/services/page_analytics_decorator.dart';

// For some magical reason I could not get the class solution to work.
// Every time I create the class that acts as a wrapper that delegates
// all possible calls to the delegate property, some assertions fail.
responsiveTransitionPage<T>({
  required ValueKey<String> key,
  required Widget child,
  required String pageName,
  required BuildContext context,
}) {
  final decoratedChild = PageAnalyticsDecorator(
    pageName: pageName,
    child: child,
  );

  if (isMobileView(context)) {
    return CustomTransitionPage<T>(
      key: key,
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation.drive(Tween(begin: 0.0, end: 1.0)),
          child: decoratedChild,
        );
      },
      child: child,
    );
  } else {
    return NoTransitionPage<T>(
      key: key,
      child: decoratedChild,
    );
  }
}
