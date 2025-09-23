import 'package:flutter/material.dart';
import 'package:phd_website/constants.dart';

/// Needs to be applied directly for the page because
/// of this issue: https://github.com/flutter/flutter/issues/129523
/// Long story short: you can't put any route inside a ListView. Incredible things happen then.
class ScrollablePageLayout extends StatelessWidget {
  final Widget page;

  const ScrollablePageLayout({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
                width: 1000,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: isMobileView(context) ? 60.0 : 30.0, left: 10, right: 10),
                  child: page,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
