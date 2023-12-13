import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class AppTitleUpdater extends StatelessWidget {
  final Widget child;
  const AppTitleUpdater({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppGlobalState>();
    final newTitle = AppLocalizations.of(context)!.appTitle;
    if (newTitle != state.applicationTitle) {
      Future.microtask(() {
        state.changeApplicationTitle(newTitle);
      });
    }
    return child;
  }
}
