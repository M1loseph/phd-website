import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String name;
  final bool selected;
  final bool hoovered;
  const SectionLabel(
      {super.key,
      required this.name,
      required this.selected,
      required this.hoovered});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context).textTheme;
    final style = width > 1000 ? theme.headlineSmall : theme.titleLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      child: Text.rich(
        TextSpan(
          text: name,
          mouseCursor: SystemMouseCursors.click,
        ),
        style: style?.copyWith(
          fontWeight: _determinFontWeight(),
        ),
      ),
    );
  }

  FontWeight _determinFontWeight() {
    if (selected) {
      return FontWeight.bold;
    }
    if (hoovered) {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }
}
