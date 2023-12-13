import 'package:flutter/material.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';

class LanguageSwitch extends StatelessWidget {
  static const polishLocale = 'pl';
  static const englishLocale = 'en';

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
                    value: lang.data == const Locale(englishLocale),
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
                  LanguageButton(
                    key: const Key('pl-button'),
                    buttonLabelLanguage: polishLocale,
                    currentLanguage: lang.data,
                  ),
                  LanguageButton(
                    key: const Key('en-button'),
                    buttonLabelLanguage: englishLocale,
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

class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
    required Locale? currentLanguage,
    required String buttonLabelLanguage,
  })  : _buttonLabelLanguage = buttonLabelLanguage,
        _currentLanguage = currentLanguage;

  final Locale? _currentLanguage;
  final String _buttonLabelLanguage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final globalState = context.watch<AppGlobalState>();
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () => globalState.setCurrentLocale(_buttonLabelLanguage),
        child: Container(
          color: isActive() ? Colors.white : theme.appBarTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 1,
              horizontal: 5,
            ),
            child: Text.rich(
              TextSpan(
                  text: _buttonLabelLanguage.toUpperCase(),
                  mouseCursor: SystemMouseCursors.click),
            ),
          ),
        ),
      ),
    );
  }

  bool isActive() {
    return _currentLanguage?.languageCode == _buttonLabelLanguage;
  }
}
