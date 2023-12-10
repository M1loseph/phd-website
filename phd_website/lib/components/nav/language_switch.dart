import 'package:flutter/material.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class LanguageSwitch extends StatelessWidget {
  final polishLocale = 'pl';
  final englishLocale = 'en';
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return FutureBuilder(
      future: globalState.getCurrentLocale(context),
      builder: (context, lang) {
        return ResponsiveLayout(
          mobileLayout: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(polishLocale.toUpperCase()),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  child: Switch(
                    value: lang.data == Locale(englishLocale),
                    activeColor: Colors.grey.shade800,
                    onChanged: (value) => globalState
                        .setCurrentLocale(value ? englishLocale : polishLocale),
                  ),
                ),
                Flexible(
                  child: Text(englishLocale.toUpperCase()),
                ),
              ],
            ),
          ),
          desktopLayout: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              color: Colors.grey.shade300,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LanguageButton(
                    language: polishLocale,
                    currentLanguage: lang.data,
                  ),
                  _LanguageButton(
                    language: englishLocale,
                    currentLanguage: lang.data,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.currentLanguage,
    required this.language,
  });

  final Locale? currentLanguage;
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
          color: currentLanguage?.languageCode == language
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
