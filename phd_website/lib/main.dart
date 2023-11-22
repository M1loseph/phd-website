import 'package:flutter/material.dart';
import 'package:phd_website/components/cookie_popup.dart';
import 'package:phd_website/components/selectable_stack.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:phd_website/layouts/navigation_layout.dart';
import 'package:go_router/go_router.dart';

import 'components/app_title_updater.dart';
import 'pages/consultation_page.dart';
import 'pages/contact_page.dart';
import 'pages/home_page.dart';
import 'pages/research_page.dart';
import 'pages/teaching_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppGlobalState(),
      ),
      Provider(
        create: (context) => BodyTextStyleService(),
      ),
    ],
    child: const PHDApp(),
  ));
}

class PHDApp extends StatefulWidget {
  const PHDApp({super.key});

  @override
  State<PHDApp> createState() => _PHDAppState();
}

class _PHDAppState extends State<PHDApp> {
  String? title;
  late GoRouter router;
  _PHDAppState() {
    router = GoRouter(
      initialLocation: "/",
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            final globalState = context.watch<AppGlobalState>();
            return Scaffold(
              body: FutureBuilder(
                future: globalState.getCurrentLocale(context),
                builder: (context, languageData) {
                  final language = languageData.data;
                  return Localizations.override(
                    context: context,
                    locale: language,
                    child: AppTitleUpdater(
                      appTitleUpdater: (newTitle) => setState(() {
                        title = newTitle;
                      }),
                      currentTitle: title,
                      child: SelectableStack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          NavigationLayout(
                            state: state,
                            currentPage: child,
                          ),
                          const CookiePopup()
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          routes: [
            GoRoute(
              path: "/",
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: const HomePage(),
                );
              },
            ),
            GoRoute(
              path: "/contact",
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: const ContactPage(),
                );
              },
            ),
            GoRoute(
              path: "/consultation",
              pageBuilder: (context, state) {
                return const NoTransitionPage(
                  child: ConsultationPage(),
                );
              },
            ),
            GoRoute(
              path: "/teaching",
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: const TeachingPage(),
                );
              },
            ),
            GoRoute(
              path: "/research",
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  key: state.pageKey,
                  child: const ResearchPage(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: title ?? "",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade100),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade200,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
