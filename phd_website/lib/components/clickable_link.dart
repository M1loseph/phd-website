import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

InlineSpan clickableInlineSpanLinkFactory({
  required String url,
  required ThemeData theme,
  TextStyle? textStyle,
}) {
  return TextSpan(
    text: url,
    mouseCursor: SystemMouseCursors.click,
    recognizer: TapGestureRecognizer()
      ..onTap = () async {
        final parsedUrl = Uri.parse(url);
        await launchUrl(parsedUrl);
      },
    style: textStyle?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
  );
}

class ClickableLink extends StatelessWidget {
  final String url;
  final TextStyle? textStyle;
  const ClickableLink({super.key, required this.url, this.textStyle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(clickableInlineSpanLinkFactory(
        url: url, theme: theme, textStyle: textStyle));
  }
}
