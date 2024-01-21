import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:phd_website/components/adapters/platform_aware_image_adapter.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/easter_egg_picture.dart';
import 'package:phd_website/layouts/page_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    final locale = AppLocalizations.of(context);
    return PageLayout(
      page: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(const Size(400, 400)),
              child: ClipOval(
                child: FutureBuilder(
                    future: globalState.getNumberOfEntires(),
                    builder: (context, asyncSnapshot) {
                      if (!asyncSnapshot.hasData ||
                          !asyncSnapshot.data!.enabled) {
                        return const PlatformAwareImageAdapter(
                          path: 'images/profile.jpg',
                        );
                      }
                      return EasterEggPicture(
                        path: 'images/profile.jpg',
                        easterEggPath: 'images/profile_sheep.jpg',
                        currentValue: asyncSnapshot.data!.value!,
                        easterEggThreshold: 10,
                      );
                    }),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                child: Text(
                  locale!.homePageName,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              BodyText(
                locale.homePageDepartment,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
