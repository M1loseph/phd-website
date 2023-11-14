import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return FutureBuilder(
      future: globalState.getCurrentLocale(context),
      builder: (context, lang) {
        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Container(
            color: Colors.grey.shade300,
            child: Row(children: [
              _LanguageButton(
                language: "pl",
                currentLaguage: lang.data,
              ),
              _LanguageButton(
                language: "en",
                currentLaguage: lang.data,
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    super.key,
    required this.currentLaguage,
    required this.language,
  });

  final Locale? currentLaguage;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final globalState = context.watch<AppGlobalState>();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () => globalState.setCurrentLocale(language),
        child: Container(
          color: currentLaguage?.languageCode == language
              ? Colors.white
              : theme.appBarTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 5,
            ),
            child: Text.rich(
              TextSpan(
                  text: language.toUpperCase(),
                  mouseCursor: SystemMouseCursors.click),
            ),
          ),
        ),
      ),
    );
  }
}
