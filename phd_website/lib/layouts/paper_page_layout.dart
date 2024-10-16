import 'package:flutter/material.dart';
import 'package:phd_website/components/footer.dart';
import 'package:phd_website/constants.dart';

class PaperPageLayout extends StatelessWidget {
  const PaperPageLayout({
    super.key,
    required this.page,
    required this.constraints,
  });

  final BoxConstraints constraints;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Container(
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
                  top: isMobileView(constraints.maxWidth) ? 100 : 150,
                ),
                child: page,
              ),
            ),
          ),
        ),
        const Footer(),
      ],
    );
  }
}
