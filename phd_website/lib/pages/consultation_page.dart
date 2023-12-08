import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';

class ConsultationPage extends StatelessWidget {
  final iconSpace = 10.0;
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return PageLayout(
      page: Center(
        child: SpacedListLayout(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home),
                SizedBox(
                  width: iconSpace,
                ),
                Flexible(
                  child: BodyText(
                    locale!.consultationPagePlace,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month),
                SizedBox(
                  width: iconSpace,
                ),
                Flexible(
                  child: BodyText(
                    locale.consultationPageDates,
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
