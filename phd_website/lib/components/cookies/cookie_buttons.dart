import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/cookies/cookie_bar_button.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class CookieButtons extends StatelessWidget {
  const CookieButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<AppGlobalState>();
    final locale = AppLocalizations.of(context)!;
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CookieBarButton(
            text: locale.componentCookiesPopup_AcceptButton,
            icon: const Icon(
              Icons.check,
              color: Color.fromARGB(255, 0, 157, 5),
            ),
            onPressed: () => globalState.acceptCookies(),
          ),
          const SizedBox(
            width: 5,
          ),
          CookieBarButton(
            text: locale.componentCookiesPopup_RejectButton,
            icon: const Icon(
              Icons.close_rounded,
              color: Color.fromARGB(255, 182, 3, 0),
            ),
            onPressed: () => globalState.rejectCookies(),
          ),
        ],
      ),
    );
  }
}
