import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'section_label.dart';

class MobileSectionNavigation extends StatelessWidget {
  final String destination;
  final String name;
  final bool selected;

  const MobileSectionNavigation({
    super.key,
    required this.destination,
    required this.name,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(destination),
        child: Row(
          children: [
            SectionLabel(
              name: name,
              selected: selected,
              hoovered: false,
            ),
          ],
        ),
      ),
    );
  }
}
