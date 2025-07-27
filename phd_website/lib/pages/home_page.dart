import 'package:flutter/material.dart';
import 'package:phd_website/components/adapters/platform_aware_image_adapter.dart';
import 'package:phd_website/components/body_text.dart';
import 'package:phd_website/components/easter_egg_picture.dart';
import 'package:phd_website/constants.dart';
import 'package:phd_website/l10n/app_localizations.dart';
import 'package:phd_website/layouts/unscrollable_page_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    final locale = AppLocalizations.of(context)!;
    return UnscrollablePageLayout(
      page: FractionallySizedBox(
        widthFactor: isMobileView(context) ? 8 / 12 : 6 / 12,
        child: Column(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: Text(
                      locale.pageHome_Name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  FittedBox(
                    child: BodyText(
                      locale.pageHome_Department,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
