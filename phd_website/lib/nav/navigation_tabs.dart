import 'package:flutter/material.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'section_navigation.dart';

class _NevigationDestination {
  final String path;
  final String name;

  _NevigationDestination({required this.name, required this.path});
}

class NavigationTabs extends StatelessWidget {
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
            children: _sectionNavigations(context),
          ),
        ),
        mobileLayout: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _sectionNavigations(context),
          ),
        ));
  }

  List<Widget> _sectionNavigations(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final destinations = [
      _NevigationDestination(name: locale!.navigationHomePage, path: "/"),
      _NevigationDestination(
          name: locale.navigationContactPage, path: "/contact"),
      _NevigationDestination(
          name: locale.navigationConsultationPage, path: "/consultation"),
      _NevigationDestination(
          name: locale.navigationTeachingPage, path: "/teaching"),
      _NevigationDestination(
          name: locale.navigationResearchPage, path: "/research"),
    ];
    return List.generate(destinations.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: SectionNavigation(
          destination: destinations[index].path,
          index: index,
          selected: destinations[index].path == _currentPath,
          name: destinations[index].name,
        ),
      );
    });
  }
}
