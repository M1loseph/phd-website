import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/components/semester_picker.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/model/semester.dart';
import 'package:phd_website/model/semester_type.dart';
import 'package:phd_website/model/semester_year.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class TeachingPage extends StatefulWidget {
  static final differentialEquationsRulesLink =
      Uri.parse('https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode');

  const TeachingPage({
    super.key,
  });

  @override
  State<TeachingPage> createState() => _TeachingPageState();
}

class _TeachingPageState extends State<TeachingPage> {
  late Semester selectedSemester;

  @override
  void initState() {
    final clock = context.read<Clock>();
    selectedSemester = Semester.currentSemester(clock);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context)!;
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTheme = bodyTextStyleService.getBodyTextStyle(context);
    return ScrollablePageLayout(
      page: Center(
        child: FractionallySizedBox(
          widthFactor: isMobileView(context) ? 1 : 10 / 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemesterPicker(
                selectSemesterCallback: (semester) {
                  setState(() {
                    selectedSemester = semester;
                  });
                },
                currentSemester: selectedSemester,
              ),
              const SizedBox(
                height: 50,
              ),
              if (selectedSemester ==
                  const Semester(SemesterYear(2023), SemesterType.winter))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.pageTeaching_DifferentialEquationsInTechnology,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      locale
                          .pageTeaching_DifferentialEquationsInTechDescription,
                      style: bodyTheme,
                    ),
                    ClickableLink(
                      uri: TeachingPage.differentialEquationsRulesLink,
                      textStyle: bodyTheme,
                    ),
                  ],
                ),
              if (selectedSemester ==
                  const Semester(SemesterYear(2024), SemesterType.winter))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.pageTeaching_IntroductionToComputerScience,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      locale.pageTeaching_IntroductionToComputerDescription,
                      style: bodyTheme,
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
