import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final appProperties = context.read<BuildProperties>();
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey.shade600,
        );
    return Container(
      height: 40,
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            locale!.componentFooter_Text(
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
