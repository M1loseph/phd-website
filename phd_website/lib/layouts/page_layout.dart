import 'package:flutter/material.dart';

/// Need to be applied directly for the page becuase
/// of this issue: https://github.com/flutter/flutter/issues/129523
class PageLayout extends StatelessWidget {
  final Widget page;

  const PageLayout({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
        child: ListView(
          children: [
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: page,
            ),
          ],
        ),
      ),
    );
  }
}
