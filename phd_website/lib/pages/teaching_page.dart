import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/components/semester_carousel.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class TeachingPage extends StatelessWidget {
  static const differentialEquationsRulesLink =
      'https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode';

  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTheme = bodyTextStyleService.getBodyTextStyle(context);
    return ScrollablePageLayout(
      page: Column(
        children: [
          const SemesterPicker(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ExpansionTile(
              title: Text(
                locale!.teachingPageDifferentialEquationsInTechnology,
                style: theme.textTheme.headlineSmall,
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale
                            .teachingPageDifferentialEquationsInTechDescription,
                        style: bodyTheme,
                      ),
                      ClickableLink(
                        url: differentialEquationsRulesLink,
                        textStyle: bodyTheme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
