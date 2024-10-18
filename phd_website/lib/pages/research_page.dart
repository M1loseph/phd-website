import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/model/conference_do.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final conferences = [
      ConferenceDO(
        conferenceName: locale
            .pageResearch_52ConferenceOnApplicationsOfMathematicsConferenceName,
        website: 'https://sites.google.com/view/lii-kzm/strona-glowna',
        talkTitle:
            locale.pageResearch_52ConferenceOnApplicationsOfMathematicsTalkTitle,
        begin: DateTime(2024, DateTime.september, 16),
        end: DateTime(2024, DateTime.september, 21),
        location: 'Kościelisko',
      ),
      ConferenceDO(
        conferenceName: locale
            .pageResearch_XIIForumOfPartialDifferentialEquationsConferenceName,
        website: 'https://sites.google.com/impan.pl/xiiifpde/',
        talkTitle:
            locale.pageResearch_XIIForumOfPartialDifferentialEquationsTalkTitle,
        begin: DateTime(2024, DateTime.june, 23),
        end: DateTime(2024, DateTime.june, 29),
        location: 'Będlewo',
      ),
      ConferenceDO(
        conferenceName: locale
            .pageResearch_51ConferenceOnApplicationsOfMathematicsConferenceName,
        website: 'https://sites.google.com/view/51-kzm/',
        talkTitle:
            locale.pageResearch_51ConferenceOnApplicationsOfMathematicsTalkTitle,
        begin: DateTime(2023, DateTime.september, 10),
        end: DateTime(2023, DateTime.september, 16),
        location: 'Kościelisko',
      ),
      ConferenceDO(
        conferenceName: locale.pageResearch_Ecmi2023ConferenceName,
        website: 'https://ecmi2023.org/',
        talkTitle: locale.pageResearch_Ecmi2023TalkTitle,
        begin: DateTime(2023, DateTime.july, 26),
        end: DateTime(2023, DateTime.july, 30),
        location: 'Wrocław',
      ),
    ];

    return ScrollablePageLayout(
      page: Center(
        child: FractionallySizedBox(
          widthFactor: isMobileView(context) ? 1 : 10 / 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: ORCiD(),
              ),
              SectionLabel(
                text: locale.pageResearch_ConferencesSectionTitle,
              ),
              for (var conference in conferences)
                ConferenceWidget(conference: conference),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
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
  static const padding = 8.0;
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

    final locale = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: Text(
                conference.conferenceName,
                style: titleStyle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: padding,
              left: padding,
              right: padding,
            ),
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
                    Flexible(
                      child: Text(
                        locale.pageResearch_ConferenceDate(
                          conference.begin,
                          conference.end,
                        ),
                        style: bodyTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text(
                  locale.pageResearch_OrganizerWebsite.toUpperCase(),
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
