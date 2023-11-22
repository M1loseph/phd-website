import 'package:flutter/material.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../state/cookies_approval.dart';
import 'cookie_bar_button.dart';

class CookiePopup extends StatelessWidget {
  const CookiePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return FutureBuilder(
        future: globalState.getCookiesApprovalStatus(),
        builder: (context, cookiesAcknowledged) {
          if (!cookiesAcknowledged.hasData ||
              cookiesAcknowledged.data != CookiesApproval.awaitingApproval) {
            return const SizedBox.shrink();
          }
          final locale = AppLocalizations.of(context);
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            color: Colors.grey.shade300,
            child: ResponsiveLayout(
              desktopLayout: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: BodyText(
                      locale!.cookiesPopupMessage,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const CookieButtons(),
                ],
              ),
              mobileLayout: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BodyText(locale.cookiesPopupMessage),
                  const SizedBox(
                    height: 10,
                  ),
                  const CookieButtons(),
                ],
              ),
            ),
          );
        });
  }
}

class CookieButtons extends StatelessWidget {
  const CookieButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final globalState = context.read<AppGlobalState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CookieBarButton(
          text: "Accept all",
          icon: Icons.check,
          onPressed: () => globalState.acceptCookies(),
        ),
        const SizedBox(
          width: 5,
        ),
        CookieBarButton(
          text: "Reject not essential",
          icon: Icons.close_rounded,
          onPressed: () => globalState.rejectCookies(),
        ),
      ],
    );
  }
}
