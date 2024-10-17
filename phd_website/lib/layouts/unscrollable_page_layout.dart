import 'package:flutter/material.dart';
import 'package:phd_website/layouts/paper_page_layout.dart';

class UnscrollablePageLayout extends StatelessWidget {
  final Widget page;
  const UnscrollablePageLayout({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return PaperPageLayout(page: page);
  }
}
