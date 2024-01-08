import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:phd_website/components/cookies/cookie_popup.dart';
import 'package:phd_website/components/selectable_stack.dart';
import 'package:phd_website/components/sweetie_easter_egg.dart';
import 'package:phd_website/layouts/navigation_layout.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/app_title_updater.dart';
import 'pages/consultation_page.dart';
import 'pages/contact_page.dart';
import 'pages/home_page.dart';
import 'pages/research_page.dart';
import 'pages/teaching_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AppGlobalState(SharedPreferences.getInstance()),
      ),
      Provider(
        create: (_) => BodyTextStyleService(),
      ),
      Provider(
        create: (_) => BuildProperties(),
      )
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
  late GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final globalState = context.watch<AppGlobalState>();
          return Scaffold(
            body: SweetieEasterEgg(
              child: FutureBuilder(
                future: globalState.getCurrentLocale(context),
                builder: (context, languageData) {
                  final language = languageData.data;
                  return Localizations.override(
                    context: context,
                    locale: language,
                    child: AppTitleUpdater(
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
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                key: state.pageKey,
                child: const HomePage(),
              );
            },
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                key: state.pageKey,
                child: const ContactPage(),
              );
            },
          ),
          GoRoute(
            path: '/consultation',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                key: state.pageKey,
                child: const ConsultationPage(),
              );
            },
          ),
          GoRoute(
            path: '/teaching',
            pageBuilder: (context, state) {
              return NoTransitionPage(
                key: state.pageKey,
                child: const TeachingPage(),
              );
            },
          ),
          GoRoute(
            path: '/research',
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppGlobalState>().bumpNumberOfEntires();
    });
  }

  @override
  Widget build(BuildContext context) {
    final globalState = context.watch<AppGlobalState>();
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: globalState.applicationTitle,
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
