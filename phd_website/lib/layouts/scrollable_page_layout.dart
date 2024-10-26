import 'package:flutter/material.dart';
import 'package:phd_website/layouts/paper_page_layout.dart';

/// Needs to be applied directly for the page because
/// of this issue: https://github.com/flutter/flutter/issues/129523
/// Long story short: you can't put any route inside a ListView. Incredible things happen then.
class ScrollablePageLayout extends StatelessWidget {
  final Widget page;

  const ScrollablePageLayout({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: PaperPageLayout(
                page: page,
              ),
            ),
          ),
        );
      },
    );
  }
}
