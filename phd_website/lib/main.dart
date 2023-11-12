import 'package:flutter/material.dart';
import 'package:phd_website/state/app_global_state.dart';
import 'package:phd_website/layouts/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'navigation/navigation_bar.dart' as navbar;
import 'package:go_router/go_router.dart';

import 'pages/consultation_page.dart';
import 'pages/contact_page.dart';
import 'pages/home_page.dart';
import 'pages/teaching_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AppGlobalState(context),
      ),
    ],
    child: App(),
  ));
}

class App extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return PageLayout(state: state, child: child);
        },
        routes: [
          GoRoute(
            path: "/",
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HomePage(),
              );
            },
          ),
          GoRoute(
            path: "/contact",
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: ContactPage(),
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
              return const NoTransitionPage(
                child: TeachingPage(),
              );
            },
          ),
          GoRoute(
            path: "/research",
            pageBuilder: (context, state) {
              return NoTransitionPage(
                child: Placeholder(
                  color: Colors.yellow,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bogna Jaszczak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade100),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade200,
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class PageLayout extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const PageLayout({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: NavigationLayout(state: state, child: child),
      ),
    );
  }
}

class NavigationLayout extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const NavigationLayout({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final nav = navbar.NavigationBar(currentPath: state.fullPath!);
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 100),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
    return ResponsiveLayout(
        desktopLayout: Column(
          children: [
            nav,
            Expanded(child: content),
          ],
        ),
        mobileLayout: Stack(
          children: [
            content,
            nav,
          ],
        ));
  }
}
