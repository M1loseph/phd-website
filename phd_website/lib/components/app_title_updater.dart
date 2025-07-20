import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phd_website/l10n/app_localizations.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class AppTitleUpdater extends StatefulWidget {
  final Widget child;
  const AppTitleUpdater({
    super.key,
    required this.child,
  });

  @override
  State<AppTitleUpdater> createState() => _AppTitleUpdaterState();
}

class _AppTitleUpdaterState extends State<AppTitleUpdater> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppGlobalState>();
    final newTitle = AppLocalizations.of(context)!.appTitle;
    if (newTitle != state.applicationTitle) {
      _timer?.cancel();
      _timer = Timer(Duration.zero, () {
        state.changeApplicationTitle(newTitle);
      });
    }
    return widget.child;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
