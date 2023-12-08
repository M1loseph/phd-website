import 'package:flutter/material.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/components/platform_aware_svg.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatelessWidget {
  final iconSpace = 10.0;
  final linkedinLogoPath = "images/linkedin_logo.svg";

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTextTheme = bodyTextStyleService.getBodyTextStyle(context);
    return PageLayout(
      page: Center(
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
                  SizedBox(
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
                  SizedBox(
                    width: 25,
                    child: PlatformAwareSvg(
                      path: linkedinLogoPath,
                      colorFilter: const ColorFilter.mode(
                          Colors.indigo, BlendMode.srcIn),
                    ),
                  ),
                  SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
