import 'package:flutter/material.dart';

class SelectableStack extends StatelessWidget {
  final List<Widget> children;
  final AlignmentGeometry alignment;

  const SelectableStack({
    super.key,
    required this.children,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: [
        for (final child in children)
          SelectionArea(
            child: child,
          ),
      ],
    );
  }
}
