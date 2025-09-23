import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/components/new_card_link.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/l10n/app_localizations.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/model/conference.dart';
import 'package:phd_website/model/publication.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final conferences = [
      Conference(
        conferenceName: '53rd Conference on Applications of Mathematics',
        website: 'https://sites.google.com/view/liiikzm/strona-glowna',
        talkTitle: 'The dynamics of lymph: a mathematical framework',
        begin: DateTime(2025, DateTime.september, 14),
        end: DateTime(2025, DateTime.september, 20),
        location: 'Kościelisko',
        details: locale.pageResearch_53rdConferenceOnApplicationsOfMathematicsDetails,
      ),
      Conference(
        conferenceName:
            'Recent Advances in Applied Mathematics',
        website: 'https://sites.google.com/pwr.edu.pl/raam-wroclaw-2024/',
        talkTitle:
            'From equations to elevations: optimizing the trail running strategy',
        begin: DateTime(2024, DateTime.december, 6),
        end: DateTime(2024, DateTime.december, 7),
        location: 'Wrocław',
      ),
      Conference(
        conferenceName:
            'On the Trails of Mathematics: Cecylia Krieger-Dunaj and Her successors',
        website: 'https://sites.google.com/impan.pl/otowim24',
        talkTitle: 'A unified model for blood and lymph flow',
        begin: DateTime(2024, DateTime.november, 8),
        end: DateTime(2024, DateTime.november, 11),
        location: 'Będlewo',
      ),
      Conference(
        conferenceName: '52nd Conference on Applications of Mathematics',
        website: 'https://sites.google.com/view/lii-kzm/strona-glowna',
        talkTitle:
            'From equations to elevations: optimizing the trail running strategy',
        begin: DateTime(2024, DateTime.september, 16),
        end: DateTime(2024, DateTime.september, 21),
        location: 'Kościelisko',
      ),
      Conference(
        conferenceName: 'XIII Forum of Partial Differential Equations',
        website: 'https://sites.google.com/impan.pl/xiiifpde/',
        talkTitle: 'A unified model for blood and lymph flow',
        begin: DateTime(2024, DateTime.june, 23),
        end: DateTime(2024, DateTime.june, 29),
        location: 'Będlewo',
      ),
      Conference(
        conferenceName: '51st Conference on Applications of Mathematics',
        website: 'https://sites.google.com/view/51-kzm/',
        talkTitle: 'Mathematical modelling of trail running',
        begin: DateTime(2023, DateTime.september, 10),
        end: DateTime(2023, DateTime.september, 16),
        location: 'Kościelisko',
      ),
      Conference(
        conferenceName: 'ECMI Conference on Industrial and Applied Mathematics',
        website: 'https://ecmi2023.org/',
        talkTitle: 'Modeling Trail Running',
        begin: DateTime(2023, DateTime.july, 26),
        end: DateTime(2023, DateTime.july, 30),
        location: 'Wrocław',
      ),
    ];

    final publications = [
      Publication(
        title:
            'Optimal strategy for trail running with nutrition and fatigue factors',
        publicationUri: 'https://epubs.siam.org/doi/abs/10.1137/24M1629936',
        preprintUri: 'https://arxiv.org/abs/2401.02919',
        publicationDate: DateTime(2024, 1, 5),
        coauthors: ['Łukasz Płociniczak'],
      ),
    ];

    return ScrollablePageLayout(
      page: Center(
        child: FractionallySizedBox(
          widthFactor: isMobileView(context) ? 1 : 10 / 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(alignment: Alignment.topRight, child: ORCiD()),
              SectionLabel(text: locale.pageResearch_PublicationsSectionTitle),
              for (var publication in publications)
                PublicationWidget(publication: publication),
              const SizedBox(height: 30),
              SectionLabel(text: locale.pageResearch_ConferencesSectionTitle),
              for (var conference in conferences)
                ConferenceWidget(conference: conference),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ORCiD extends StatelessWidget {
  static final _orcidUrl = Uri.parse('https://orcid.org/0009-0008-3835-9170');

  const ORCiD({super.key});

  @override
  Widget build(BuildContext context) {
    return NewCardLink(
      child: IconButton(
        icon: const PlatformAwareSvgAdapter(
          path: 'images/orcid_logo.svg',
          width: 150,
        ),
        hoverColor: Colors.transparent,
        onPressed: () async {
          await launchUrl(_orcidUrl);
        },
      ),
    );
  }
}

class PublicationWidget extends StatelessWidget {
  static const padding = 8.0;

  final Publication publication;

  const PublicationWidget({super.key, required this.publication});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context)!;
    final formatter = DateFormat('yMMMMd', locale.localeName);

    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    final archiveUri = publication.preprintUri;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          spacing: 2,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('"${publication.title}"', style: titleStyle),
            const SizedBox(height: padding),
            Text(
              locale.pageResearch_PublicationCoauthorsLabel(
                publication.coauthors.join(', '),
              ),
            ),
            const SizedBox(height: padding * 2),
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 10),
                Flexible(
                  child: ClickableLink(
                    uri: publication.publicationUri,
                    textStyle: bodyTextStyle,
                  ),
                ),
              ],
            ),
            archiveUri != null
                ? Row(
                    children: [
                      const Icon(FontAwesomeIcons.newspaper),
                      const SizedBox(width: 10),
                      Flexible(child: BodyText('Preprint')),
                      const SizedBox(width: 10),
                      Flexible(
                        child: ClickableLink(
                          uri: archiveUri,
                          textStyle: bodyTextStyle,
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            Row(
              children: [
                const Icon(FontAwesomeIcons.calendar),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    formatter.format(publication.publicationDate),
                    style: bodyTextStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConferenceWidget extends StatelessWidget {
  static const padding = 8.0;

  final Conference conference;

  const ConferenceWidget({super.key, required this.conference});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    final locale = AppLocalizations.of(context)!;
    final details = conference.details;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          spacing: 2,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(conference.conferenceName, style: titleStyle),
            const SizedBox(height: padding * 2),
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
                const Icon(FontAwesomeIcons.calendar),
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
            details != null ?
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(FontAwesomeIcons.award),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    details,
                    style: bodyTextStyle,
                  ),
                ),
              ],
            ) : SizedBox.shrink(),
            Align(
              alignment: Alignment.centerRight,
              child: NewCardLink(
                iconSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(text, style: theme.textTheme.displaySmall),
    );
  }
}
