import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/layouts/responsive_layout.dart';

import 'section_navigation.dart';

class _NavigationDestination {
  final String path;
  final String name;

  _NavigationDestination({required this.name, required this.path});
}

class NavigationTabs extends StatelessWidget {
  final String _currentPath;

  const NavigationTabs({
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
        mobileLayout: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _sectionNavigations(context),
        ));
  }

  List<Widget> _sectionNavigations(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final destinations = [
      _NavigationDestination(name: locale!.navigationHomePage, path: '/'),
      _NavigationDestination(
          name: locale.navigationContactPage, path: '/contact'),
      _NavigationDestination(
          name: locale.navigationConsultationPage, path: '/consultation'),
      _NavigationDestination(
          name: locale.navigationTeachingPage, path: '/teaching'),
      _NavigationDestination(
          name: locale.navigationResearchPage, path: '/research'),
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
