import 'package:flutter/material.dart';

class SpacedListLayout extends StatelessWidget {
  final List<Widget> _children;
  const SpacedListLayout({super.key, required List<Widget> children})
      : _children = children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
            _children.length,
            (index) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _children[index],
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                  ],
                ))
      ],
    );
  }
}
