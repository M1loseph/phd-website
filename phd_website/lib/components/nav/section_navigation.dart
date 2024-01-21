import 'package:flutter/material.dart';
import 'package:phd_website/components/nav/desktop_section_navigation.dart';
import 'package:phd_website/components/nav/mobile_section_navigation.dart';
import 'package:phd_website/layouts/responsive_layout.dart';

class SectionNavigation extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      desktopLayout: DesktopSectionNavigation(
        destination: destination,
        name: name,
        selected: selected,
      ),
      mobileLayout: MobileSectionNavigation(
        destination: destination,
        name: name,
        selected: selected,
      ),
    );
  }
}
