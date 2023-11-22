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
    final locale = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CookieBarButton(
          text: locale!.cookiesPopupAcceptButton,
          icon: Icons.check,
          onPressed: () => globalState.acceptCookies(),
        ),
        const SizedBox(
          width: 5,
        ),
        CookieBarButton(
          text: locale.cookiesPopupRejectButton,
          icon: Icons.close_rounded,
          onPressed: () => globalState.rejectCookies(),
        ),
      ],
    );
  }
}
