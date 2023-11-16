import 'package:flutter/material.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:phd_website/text_theme_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactPage extends StatelessWidget {
  final iconSpace = 10.0;
  final linkedinLogoPath = "images/linkedin_logo.png";

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = TextThemeService.getBodyTextStyle(context);
    final locale = AppLocalizations.of(context);
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
                    child: Text(
                      locale!.contactPageEmail,
                      style: textTheme,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Image.asset(linkedinLogoPath),
                  ),
                  SizedBox(
                    width: iconSpace,
                  ),
                  Expanded(
                    child: ClickableLink(
                      url: locale.contactPageLinkedinURL,
                      textStyle: textTheme,
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
