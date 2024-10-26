import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

InlineSpan clickableInlineSpanLinkFactory({
  required Uri uri,
  required ThemeData theme,
  TextStyle? textStyle,
}) {
  return TextSpan(
    text: uri.toString(),
    mouseCursor: SystemMouseCursors.click,
    recognizer: TapGestureRecognizer()
      ..onTap = () async {
        await launchUrl(uri);
      },
    style: textStyle?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
    ),
  );
}

class ClickableLink extends StatelessWidget {
  final Uri uri;
  final TextStyle? textStyle;

  const ClickableLink({
    super.key,
    required this.uri,
    this.textStyle,
  });

  ClickableLink.fromString({
    super.key,
    required String uri,
    this.textStyle,
  }) : uri = Uri.parse(uri);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      clickableInlineSpanLinkFactory(
        uri: uri,
        theme: theme,
        textStyle: textStyle,
      ),
    );
  }
}
