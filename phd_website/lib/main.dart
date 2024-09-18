import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:phd_website/build_properties/build_properties.dart';
import 'package:phd_website/clock/clock.dart';
import 'package:phd_website/components/app_title_updater.dart';
import 'package:phd_website/components/cookies/cookie_popup.dart';
import 'package:phd_website/components/selectable_stack.dart';
import 'package:phd_website/components/sweetie_easter_egg.dart';
import 'package:phd_website/layouts/navigation_layout.dart';
import 'package:phd_website/pages/consultation_page.dart';
import 'package:phd_website/pages/contact_page.dart';
import 'package:phd_website/pages/home_page.dart';
import 'package:phd_website/pages/research_page.dart';
import 'package:phd_website/pages/teaching_page.dart';
import 'package:phd_website/responsive_transition_page.dart';
import 'package:phd_website/services/analytics_service.dart';
import 'package:phd_website/services/body_text_style_service.dart';
import 'package:phd_website/services/clipboard_service.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => AppGlobalState(SharedPreferences.getInstance()),
      ),
      Provider(create: (_) => BodyTextStyleService()),
      Provider<BuildProperties>(create: (_) => GitBuildProperties()),
      Provider(create: (_) => ClipboardService()),
      Provider(
        create: (_) => AnalyticsService(
          analyticsUrl: const String.fromEnvironment('ANALYTICS_SERVER_URL'),
          environment: const String.fromEnvironment('ENVIRONMENT'),
          httpClient: Client(),
          clock: Clock(),
        ),
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
              return responsiveTransitionPage(
                key: state.pageKey,
                pageName: 'home',
                child: const HomePage(),
                context: context,
              );
            },
          ),
          GoRoute(
            path: '/contact',
            pageBuilder: (context, state) {
              return responsiveTransitionPage(
                key: state.pageKey,
                pageName: 'contact',
                child: const ContactPage(),
                context: context,
              );
            },
          ),
          GoRoute(
            path: '/consultation',
            pageBuilder: (context, state) {
              return responsiveTransitionPage(
                key: state.pageKey,
                pageName: 'consultation',
                child: const ConsultationPage(),
                context: context,
              );
            },
          ),
          GoRoute(
            path: '/teaching',
            pageBuilder: (context, state) {
              return responsiveTransitionPage(
                key: state.pageKey,
                pageName: 'teaching',
                child: const TeachingPage(),
                context: context,
              );
            },
          ),
          GoRoute(
            path: '/research',
            pageBuilder: (context, state) {
              return responsiveTransitionPage(
                key: state.pageKey,
                pageName: 'research',
                child: const ResearchPage(),
                context: context,
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
    context.read<AppGlobalState>().bumpNumberOfEntires();
    context.read<AnalyticsService>().registerAppOpenedEvent();
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
