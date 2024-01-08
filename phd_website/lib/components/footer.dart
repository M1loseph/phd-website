import 'package:flutter/material.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  static const height = 40.0;
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final appProperties = context.read<BuildProperties>();
    return Container(
      height: height,
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Copyright © ${appProperties.lastBuildYear} Version: ${appProperties.appVersion}'),
        ],
      ),
    );
  }
}
