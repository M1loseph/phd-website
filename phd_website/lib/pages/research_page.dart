import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/model/conference_do.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final conferences = [
      ConferenceDO(
        conferenceName: locale!.researchPageEcmi2023ConferenceName,
        website: 'https://ecmi2023.org/',
        talkTitle: locale.researchPageEcmi2023TalkTitle,
        date: DateTime(2023, DateTime.july, 26),
        location: 'Wrocław',
      ),
      ConferenceDO(
        conferenceName: locale
            .researchPage51ConferenceOnApplicationsOfMathematicsConferenceName,
        website: 'https://sites.google.com/view/51-kzm/',
        talkTitle:
            locale.researchPage51ConferenceOnApplicationsOfMathematicsTalkTitle,
        date: DateTime(2023, DateTime.september, 10),
        location: 'Kościelisko',
      ),
    ];

    return PageLayout(
      page: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: ORCiD(),
              ),
              SectionLabel(
                text: locale.researchPageConferencesSectionTitle,
              ),
              for (var conference in conferences)
                ConferenceWidget(conference: conference),
            ],
          ),
        ],
      ),
    );
  }
}

class ORCiD extends StatelessWidget {
  static const _orcidUrl = 'https://orcid.org/0009-0008-3835-9170';
  const ORCiD({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: IntrinsicWidth(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const PlatformAwareSvgAdapter(
                  path: 'images/orcid_logo.svg',
                  width: 150,
                ),
                hoverColor: Colors.transparent,
                onPressed: () async {
                  await launchUrl(Uri.parse(_orcidUrl));
                },
              ),
            ),
            const Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                CupertinoIcons.arrow_up_right_circle_fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConferenceWidget extends StatelessWidget {
  const ConferenceWidget({
    super.key,
    required this.conference,
  });

  final ConferenceDO conference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    final locale = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMMd(locale?.localeName);
    return Card(
      surfaceTintColor: Colors.grey[800],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              conference.conferenceName,
              style: titleStyle,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.co_present_outlined),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          '"${conference.talkTitle}"',
                          style: bodyTextStyle,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined),
                      const SizedBox(width: 10),
                      Text(
                        dateFormat.format(conference.date),
                        style: bodyTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text(
                  locale!.researchPageOrganizerWebsite.toUpperCase(),
                  style: bodyTextStyle,
                ),
                onPressed: () async {
                  await launchUrl(conference.website);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
      ),
      child: Text(
        text,
        style: theme.textTheme.displaySmall,
      ),
    );
  }
}
