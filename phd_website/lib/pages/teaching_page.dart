import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeachingPage extends StatelessWidget {
  const TeachingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: ExpansionTile(
            title: Text(
              "Równania różniczkowe w technice",
              style: theme.textTheme.headlineSmall,
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "Zasady zaliczenia oraz listy znajdują się na stronie wykładowcy."),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(
                            "https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode");
                        await launchUrl(url);
                      },
                      child: Text.rich(
                        const TextSpan(
                          text:
                              "https://prac.im.pwr.edu.pl/~plociniczak/doku.php?id=ode",
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
    );
  }
}
