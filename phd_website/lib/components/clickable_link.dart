import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableLink extends StatelessWidget {
  final String url;
  final TextStyle? textStyle;
  const ClickableLink({super.key, required this.url, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        final parsedUrl = Uri.parse(url);
        await launchUrl(parsedUrl);
      },
      child: Text.rich(
        TextSpan(
          text: url,
          mouseCursor: SystemMouseCursors.click,
        ),
        style: textStyle?.copyWith(
          color: theme.colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
