import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatelessWidget {
  static const iconSpace = 10.0;
  static const iconSize = 25.0;
  static const linkedinLogoPath = 'images/linkedin_logo.svg';
  static const stravaLogoPath = 'images/strava_logo.svg';

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTextTheme = bodyTextStyleService.getBodyTextStyle(context);
    return PageLayout(
      page: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SpacedListLayout(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.email,
                      ),
                      const SizedBox(
                        width: iconSpace,
                      ),
                      Expanded(
                        child: BodyText(
                          locale!.contactPageEmail,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: iconSize,
                        child: PlatformAwareSvgAdapter(
                          path: linkedinLogoPath,
                          colorFilter:
                              ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(
                        width: iconSpace,
                      ),
                      Expanded(
                        child: ClickableLink(
                          url: locale.contactPageLinkedinURL,
                          textStyle: bodyTextTheme,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: PlatformAwareSvgAdapter(
                          path: stravaLogoPath,
                        ),
                      ),
                      const SizedBox(
                        width: iconSpace,
                      ),
                      Expanded(
                        child: ClickableLink(
                          url: locale.contactPageStravaURL,
                          textStyle: bodyTextTheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
