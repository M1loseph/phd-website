import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SectionNavigation extends StatefulWidget {
  final int index;
  final String destination;
  final String name;
  final bool selected;

  const SectionNavigation(
      {super.key,
      required this.destination,
      required this.index,
      required this.selected,
      required this.name});

  @override
  State<SectionNavigation> createState() => _SectionNavigationState();
}

class _SectionNavigationState extends State<SectionNavigation> {
  bool hoovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => hoovered = true),
      onExit: (event) => setState(() => hoovered = false),
      child: GestureDetector(
        onTap: () => context.go(widget.destination),
        child: Text.rich(
          TextSpan(
            text: widget.name,
            mouseCursor: SystemMouseCursors.click,
          ),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: _determinFontWeight(),
              ),
        ),
      ),
    );
  }

  FontWeight _determinFontWeight() {
    if (widget.selected) {
      return FontWeight.bold;
    }
    if (hoovered) {
      return FontWeight.bold;
    }
    return FontWeight.normal;
  }
}
