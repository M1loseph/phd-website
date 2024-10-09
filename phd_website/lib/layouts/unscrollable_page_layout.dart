import 'package:flutter/material.dart';
import 'package:phd_website/components/footer.dart';
import 'package:phd_website/constants.dart';

// TODO: extract copied code from ScrollablePageLayout to some new widget
class UnscrollablePageLayout extends StatelessWidget {
  final Widget page;
  const UnscrollablePageLayout({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return Column(
          children: [
            Center(
              child: Container(
                height: constrains.maxHeight - Footer.height,
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
                    top: isMobileView(constrains.maxWidth) ? 100 : 150,
                  ),
                  child: page,
                ),
              ),
            ),
            const Footer(),
          ],
        );
      }
    );
  }
}
