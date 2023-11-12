import 'package:flutter/material.dart';
import 'package:phd_website/layouts/responsive_layout.dart';

import 'section_navigation.dart';

class _NevigationDestination {
  final String path;
  final String name;

  _NevigationDestination({required this.name, required this.path});
}

class NavigationTabs extends StatelessWidget {
  final List<_NevigationDestination> _destinations = [
    _NevigationDestination(path: "/", name: "Strona główna"),
    _NevigationDestination(name: "Kontakt", path: "/contact"),
    _NevigationDestination(name: "Konsultacje", path: "/consultation"),
    _NevigationDestination(name: "Dydaktyka", path: "/teaching"),
    _NevigationDestination(name: "Publikacje", path: "/research"),
  ];
  final String _currentPath;

  NavigationTabs({
    super.key,
    required String currentPath,
  }) : _currentPath = currentPath;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
        desktopLayout: Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _sectionNavigations(),
          ),
        ),
        mobileLayout: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _sectionNavigations(),
          ),
        ));
  }

  List<Widget> _sectionNavigations() {
    return List.generate(_destinations.length, (index) {
      return Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: SectionNavigation(
          destination: _destinations[index].path,
          index: index,
          selected: _destinations[index].path == _currentPath,
          name: _destinations[index].name,
        ),
      );
    });
  }
}
