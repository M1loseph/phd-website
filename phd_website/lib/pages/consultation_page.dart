import 'package:flutter/material.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/l10n/app_localizations.dart';
import 'package:phd_website/layouts/scrollable_page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return ScrollablePageLayout(
      page: Column(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: isMobileView(context)
                  ? (8 / 12)
                  : (6 / 12),
              child: SpacedListLayout(
                children: [
                  ConsultationEntry(
                    text: locale.pageConsultation_EmailReminder,
                    icon: Icons.email,
                  ),
                  ConsultationEntry(
                    text: locale.pageConsultation_Place,
                    icon: Icons.home,
                  ),
                  ConsultationEntry(
                    icon: Icons.calendar_month,
                    text: locale.pageConsultation_Dates,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConsultationEntry extends StatelessWidget {
  static const iconSpace = 10.0;

  const ConsultationEntry({
    super.key,
    required this.text,
    required this.icon,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(
          width: iconSpace,
        ),
        Flexible(
          child: BodyText(text),
        ),
      ],
    );
  }
}
