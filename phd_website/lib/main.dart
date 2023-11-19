import 'package:flutter/material.dart';
import 'package:phd_website/components/cookie_popup.dart';
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
    ],
    child: const RouterConfig(),
  ));
}

class RouterConfig extends StatefulWidget {
  const RouterConfig({super.key});

  @override
  State<RouterConfig> createState() => _RouterConfigState();
}

class _RouterConfigState extends State<RouterConfig> {
  String? title;
  late GoRouter router;
  _RouterConfigState() {
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
                    child: SelectionArea(
                      child: AppTitleUpdater(
                        appTitleUpdater: (newTitle) => setState(() {
                          title = newTitle;
                        }),
                        currentTitle: title,
                        child: Stack(
                          children: [
                            Expanded(
                              child: NavigationLayout(
                                state: state,
                                currentPage: child,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.bottomCenter,
                              child: CookiePopup(),
                            )
                          ],
                        ),
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
