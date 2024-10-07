import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return PageLayout(
      page: Column(
        children: [
          Center(
            child: SpacedListLayout(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ConsultationEntry(
                      text:
                          locale!.consultationPageEmailReminder,
                      icon: Icons.email),
                ),
                ConsultationEntry(
                  text: locale.consultationPagePlace,
                  icon: Icons.home,
                ),
                ConsultationEntry(
                  icon: Icons.calendar_month,
                  text: locale.consultationPageDates,
                ),
              ],
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
