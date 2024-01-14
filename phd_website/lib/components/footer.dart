import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  static const height = 40.0;
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final appProperties = context.read<BuildProperties>();
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        );
    return Container(
      height: height,
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            locale!.footer(
              appProperties.lastBuildYear,
              appProperties.appVersion,
            ),
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
