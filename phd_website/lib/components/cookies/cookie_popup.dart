import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/cookies/cookie_buttons.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/state/cookies_approval.dart';
import 'package:provider/provider.dart';

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
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.shade300,
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            child: ResponsiveLayout(
              desktopLayout: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Icon(
                      Icons.cookie,
                      color: Colors.brown,
                    ),
                  ),
                  Flexible(
                    child: BodyText(
                      locale!.componentCookiesPopup_Message,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.cookie,
                          color: Colors.brown,
                        ),
                      ),
                      Flexible(child: BodyText(locale.componentCookiesPopup_Message)),
                    ],
                  ),
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
