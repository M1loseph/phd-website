import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/layouts/page_layout.dart';

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
    final textStyle = theme.textTheme.bodyMedium;

    final locale = AppLocalizations.of(context);

    final conferences = [
      _Conference(
        conferenceName: locale!.conferencePageEcmi2023ConferenceName,
        website: locale.conferencePageEcmi2023Website,
        talkTitle: locale.conferencePageEcmi2023TalkTitle,
      ),
      _Conference(
        conferenceName: locale
            .conferencePage51ConferenceOnApplicationsOfMathematicsConferenceName,
        website:
            locale.conferencePage51ConferenceOnApplicationsOfMathematicsWebsite,
        talkTitle: locale
            .conferencePage51ConferenceOnApplicationsOfMathematicsTalkTitle,
      ),
    ];

    return PageLayout(
      page: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                  left: 15,
                  right: 15,
                ),
                child: Text(
                  locale.conferencePageConferencesSectionTitle,
                  style: theme.textTheme.displaySmall,
                ),
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
                                        text: locale.conferencePageTalkTitle,
                                        style: textStyle,
                                      ),
                                      TextSpan(
                                        text: conference.talkTitle,
                                        style: textStyle?.copyWith(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: locale
                                            .conferencePageOrganizerWebsite,
                                        style: textStyle,
                                      ),
                                      clickableInlineSpanLinkFactory(
                                        url: conference.website,
                                        theme: theme,
                                        textStyle: textStyle,
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
            ],
          ),
        ],
      ),
    );
  }
}
