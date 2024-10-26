import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/constants.dart';
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
        conferenceName: locale
            .pageResearch_52ConferenceOnApplicationsOfMathematicsConferenceName,
        website: 'https://sites.google.com/view/lii-kzm/strona-glowna',
        talkTitle:
            'From equations to elevations: optimizing the trail running strategy',
        begin: DateTime(2024, DateTime.september, 16),
        end: DateTime(2024, DateTime.september, 21),
        location: 'Kościelisko',
      ),
      Conference(
        conferenceName: locale
            .pageResearch_XIIForumOfPartialDifferentialEquationsConferenceName,
        website: 'https://sites.google.com/impan.pl/xiiifpde/',
        talkTitle: 'A unified model for blood and lymph flow',
        begin: DateTime(2024, DateTime.june, 23),
        end: DateTime(2024, DateTime.june, 29),
        location: 'Będlewo',
      ),
      Conference(
        conferenceName: locale
            .pageResearch_51ConferenceOnApplicationsOfMathematicsConferenceName,
        website: 'https://sites.google.com/view/51-kzm/',
        talkTitle: 'Mathematical modelling of trail running',
        begin: DateTime(2023, DateTime.september, 10),
        end: DateTime(2023, DateTime.september, 16),
        location: 'Kościelisko',
      ),
      Conference(
        conferenceName: locale.pageResearch_Ecmi2023ConferenceName,
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
        archiveUri: 'https://arxiv.org/abs/2401.02919',
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
              const Align(
                alignment: Alignment.topRight,
                child: ORCiD(),
              ),
              SectionLabel(
                text: locale.pageResearch_PublicationsSectionTitle,
              ),
              for (var publication in publications)
                PublicationWidget(
                  publication: publication,
                ),
              const SizedBox(
                height: 30,
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
  static final _orcidUrl = Uri.parse('https://orcid.org/0009-0008-3835-9170');

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
                  await launchUrl(_orcidUrl);
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

// TODO: try to remove duplications across PublicationWidget and ConferenceWidget
class PublicationWidget extends StatelessWidget {
  static const padding = 8.0;

  final Publication publication;

  const PublicationWidget({
    super.key,
    required this.publication,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context)!;
    final formatter = DateFormat('yMMMMd', locale.localeName);

    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '"${publication.title}"',
              style: titleStyle,
            ),
            const SizedBox(
              height: padding,
            ),
            Text(
              locale.pageResearch_PublicationCoauthorsLabel(
                publication.coauthors.join(', '),
              ),
            ),
            const SizedBox(
              height: padding * 2,
            ),
            Row(
              children: [
                const Icon(Icons.link),
                const SizedBox(width: 10),
                Flexible(
                  child: ClickableLink(
                    uri: publication.archiveUri,
                    textStyle: bodyTextStyle,
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

  const ConferenceWidget({
    super.key,
    required this.conference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall;
    final textThemeService = context.read<BodyTextStyleService>();
    final bodyTextStyle = textThemeService.getBodyTextStyle(context);

    final locale = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conference.conferenceName,
              style: titleStyle,
            ),
            const SizedBox(
              height: padding * 2,
            ),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  locale.pageResearch_OrganizerWebsite.toUpperCase(),
                  style: bodyTextStyle,
                ),
                onPressed: () async {
                  await launchUrl(conference.website);
                },
              ),
            )
          ],
        ),
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
