import 'package:flutter/material.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:provider/provider.dart';

class BodyText extends StatelessWidget {
  final String text;
  const BodyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final textStyle = bodyTextStyleService.getBodyTextStyle(context);
    return Text(
      text,
      style: textStyle,
    );
  }
}
