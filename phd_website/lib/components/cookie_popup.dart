import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CookiePopup extends StatelessWidget {
  const CookiePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return FutureBuilder(
        future: globalState.areCookiesAcknowledged(),
        builder: (context, cookiesAcknowledged) {
          if (!cookiesAcknowledged.hasData || cookiesAcknowledged.data!) {
            return const SizedBox.shrink();
          }
          final theme = Theme.of(context);
          final locale = AppLocalizations.of(context);
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.grey.shade300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    locale!.cookiesPopupMessage,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => globalState.acknowledgeCookies(),
                    child: const Icon(Icons.close_rounded),
                  ),
                )
              ],
            ),
          );
        });
  }
}
