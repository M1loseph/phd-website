import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return ListView(
      children: [
        const SizedBox(
          height: 100,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size(400, 400)),
                child: ClipOval(
                  child: Image.asset(
                    "images/profile.jpg",
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  locale.homePageDepartment,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
