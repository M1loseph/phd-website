import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeachingPage extends StatelessWidget {
  final diferentialEquasionsRulesLink =
      "https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode";
  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(
          height: 100,
        ),
        Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ExpansionTile(
                title: Text(
                  locale!.teachingPageDifferentialEquasionsInTech,
                  style: theme.textTheme.headlineSmall,
                ),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale
                            .teachingPageDifferentialEquasionsInTechDescription),
                        GestureDetector(
                          onTap: () async {
                            final url =
                                Uri.parse(diferentialEquasionsRulesLink);
                            await launchUrl(url);
                          },
                          child: Text.rich(
                            TextSpan(
                              text: diferentialEquasionsRulesLink,
                              mouseCursor: SystemMouseCursors.click,
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }
}
