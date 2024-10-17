import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/components/semester_picker.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class TeachingPage extends StatefulWidget {
  static const differentialEquationsRulesLink =
      'https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode';
  final Clock clock;

  const TeachingPage({
    super.key,
    required this.clock,
  });

  @override
  State<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends State<TeachingPage> {
  Semester? selectedSemester;

  @override
  void initState() {
    selectedSemester = Semester.currentSemester(widget.clock);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTheme = bodyTextStyleService.getBodyTextStyle(context);
    return ScrollablePageLayout(
      page: Center(
        child: FractionallySizedBox(
          widthFactor:
              isMobileView(context) ? 1 : 10 / 12,
          child: Column(
            children: [
              SemesterPicker(
                selectSemesterCallback: (semester) {
                  setState(() {
                    selectedSemester = semester;
                  });
                },
              ),
              const SizedBox(
                height: 50,
              ),
              if (selectedSemester ==
                  const Semester(SemesterYear(2023), SemesterType.winter))
                ExpansionTile(
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
                            url: TeachingPage.differentialEquationsRulesLink,
                            textStyle: bodyTheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (selectedSemester ==
                  const Semester(SemesterYear(2024), SemesterType.winter))
                ExpansionTile(
                  title: Text(
                    locale!.teachingPageIntroductionToComputerScience,
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
                            url: TeachingPage.differentialEquationsRulesLink,
                            textStyle: bodyTheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
