import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppTitleUpdater extends StatelessWidget {
  final void Function(String) appTitleUpdater;
  final String? currentTitle;
  final Widget child;
  const AppTitleUpdater({
    super.key,
    required this.appTitleUpdater,
    required this.child,
    required this.currentTitle,
  });

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      final newTitle = AppLocalizations.of(context)!.appTitle;
      if (newTitle != currentTitle) {
        appTitleUpdater(newTitle);
      }
    });
    return child;
  }
}
