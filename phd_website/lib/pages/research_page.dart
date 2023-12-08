import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class _Conference {
  final String conferenceName;
  final String website;
  final String talkTitle;

  _Conference({
    required this.conferenceName,
    required this.website,
    required this.talkTitle,
  });
}

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    final locale = AppLocalizations.of(context);

    final conferences = [
      _Conference(
        conferenceName: locale!.researchPageEcmi2023ConferenceName,
        website: locale.researchPageEcmi2023Website,
        talkTitle: locale.researchPageEcmi2023TalkTitle,
      ),
      _Conference(
        conferenceName: locale
            .researchPage51ConferenceOnApplicationsOfMathematicsConferenceName,
        website:
            locale.researchPage51ConferenceOnApplicationsOfMathematicsWebsite,
        talkTitle:
            locale.researchPage51ConferenceOnApplicationsOfMathematicsTalkTitle,
      ),
    ];

    return PageLayout(
      page: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                text: locale.researchPageConferencesSectionTitle,
              ),
              for (var conference in conferences)
                Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ExpansionTile(
                        title: Text(
                          conference.conferenceName,
                          style: titleStyle,
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: locale.researchPageTalkTitle,
                                        style: bodyTextStyle,
                                      ),
                                      TextSpan(
                                        text: conference.talkTitle,
                                        style: bodyTextStyle?.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            locale.researchPageOrganizerWebsite,
                                        style: bodyTextStyle,
                                      ),
                                      clickableInlineSpanLinkFactory(
                                        url: conference.website,
                                        theme: theme,
                                        textStyle: bodyTextStyle,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SectionLabel(
                  text: locale.researchPageOrcidNumberLabel,
                ),
              ),
              ClickableLink(
                url: "https://orcid.org/0009-0008-3835-9170",
                textStyle: bodyTextStyle,
              ),
            ],
          ),
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
