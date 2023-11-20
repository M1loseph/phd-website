import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/platform_aware_image.dart';
import 'package:phd_website/layouts/page_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return PageLayout(
      page: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(const Size(400, 400)),
              child: const ClipOval(
                child: PlatformAwareImage(
                  path: "images/profile.jpg",
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locale!.homePageName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(
                locale.homePageAbout,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                locale.homePageDepartment,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
