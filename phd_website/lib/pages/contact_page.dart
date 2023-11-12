import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  final iconSpace = 10.0;
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final globalAppState = context.watch<AppGlobalState>();
    final textTheme = globalAppState.getMainContextTextStyle();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SpacedListLayout(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.email,
                ),
                SizedBox(
                  width: iconSpace,
                ),
                Text(
                  "bogna.jaszczak@pwr.edu.pl",
                  style: textTheme,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Image.asset("images/linkedin_logo.png"),
                ),
                SizedBox(
                  width: iconSpace,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(
                          "https://www.linkedin.com/in/bogna-jaszczak-228aab1b4/");
                      await launchUrl(uri);
                    },
                    child: Text.rich(
                      TextSpan(
                        mouseCursor: SystemMouseCursors.click,
                        text:
                            "https://www.linkedin.com/in/ bogna-jaszczak-228aab1b4/",
                        style: textTheme?.copyWith(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
