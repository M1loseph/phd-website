import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/adapters/platform_aware_svg_adapter.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/clickable_link.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/layouts/spaced_list_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:phd_website/services/clipboard_service.dart';
import 'package:provider/provider.dart';

class ContactPage extends StatelessWidget {
  static const iconSpace = 10.0;
  static const iconSize = 25.0;
  static const linkedinLogoPath = 'images/linkedin_logo.svg';
  static const stravaLogoPath = 'images/strava_logo.svg';

  static const email = 'bogna.jaszczak@pwr.edu.pl';
  static const stravaLink = 'https://www.strava.com/athletes/74296734';
  static const linkedInLink =
      'https://www.linkedin.com/in/bogna-jaszczak-228aab1b4/';

  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bodyTextStyleService = context.read<BodyTextStyleService>();
    final bodyTextTheme = bodyTextStyleService.getBodyTextStyle(context);
    return PageLayout(
      page: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SpacedListLayout(
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.email,
                      ),
                      SizedBox(
                        width: iconSpace,
                      ),
                      Flexible(
                        child: BodyText(email),
                      ),
                      CopyButton(copyValue: email, iconSize: iconSize),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: iconSize,
                        child: PlatformAwareSvgAdapter(
                          path: linkedinLogoPath,
                          colorFilter:
                              ColorFilter.mode(Colors.indigo, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(
                        width: iconSpace,
                      ),
                      Expanded(
                        child: ClickableLink(
                          url: linkedInLink,
                          textStyle: bodyTextTheme,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: PlatformAwareSvgAdapter(
                          path: stravaLogoPath,
                        ),
                      ),
                      const SizedBox(
                        width: iconSpace,
                      ),
                      Expanded(
                        child: ClickableLink(
                          url: stravaLink,
                          textStyle: bodyTextTheme,
                        ),
                      ),
                    ],
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

class CopyButton extends StatefulWidget {
  final String copyValue;
  final double iconSize;

  const CopyButton({
    super.key,
    required this.copyValue,
    required this.iconSize,
  });

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _isCopied = false;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final clipboardService = context.read<ClipboardService>();
    final locale = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await clipboardService.copyToClipboard(widget.copyValue);
              setState(() {
                _isCopied = true;
                _timer?.cancel();
                _timer = Timer(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _isCopied = false;
                    });
                  }
                });
              });
            },
            iconSize: widget.iconSize - 5,
          ),
          Transform.translate(
            offset: const Offset(40, 0),
            child: AnimatedOpacity(
              opacity: _isCopied ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(locale!.contactPageCopiedPopup),
            ),
          )
        ],
      ),
    );
  }
}
