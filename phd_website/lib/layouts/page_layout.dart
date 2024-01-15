import 'package:flutter/material.dart';
import 'package:phd_website/components/footer.dart';
import 'package:phd_website/constants.dart';

/// Needs to be applied directly for the page because
/// of this issue: https://github.com/flutter/flutter/issues/129523
/// Long story short: you can't put any route inside a ListView. Incredible things happen then.
class PageLayout extends StatelessWidget {
  final Widget page;

  const PageLayout({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      return ListView(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(
                  minHeight: constrains.maxHeight - Footer.height),
              width: 1000,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: isMobileView(constrains.maxWidth) ? 100 : 150),
                child: page,
              ),
            ),
          ),
          const Footer(),
        ],
      );
    });
  }
}
