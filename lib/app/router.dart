import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/analytics/presentation/analytics_screen.dart';
import '../features/calendar/presentation/calendar_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dev/foundations_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import 'shell/app_shell.dart';
import 'shell/destinations.dart';

/// Route map: docs/04-navigation-and-flows.md. Splash/auth/onboarding routes
/// and the authState redirect arrive with step 5.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppDestination.dashboard.path,
    routes: [
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        navigatorContainerBuilder: (context, shell, children) =>
            AppShell(shell: shell, children: children),
        branches: [
          _branch(AppDestination.dashboard, const DashboardScreen()),
          _branch(AppDestination.journal, const JournalScreen()),
          _branch(AppDestination.calendar, const CalendarScreen()),
          _branch(AppDestination.analytics, const AnalyticsScreen()),
        ],
      ),
      // Developer-only component sheet. Not linked from any screen and not
      // registered in release builds; open it with
      // `flutter run --route /dev/foundations`.
      if (kDebugMode)
        GoRoute(
          path: '/dev/foundations',
          builder: (context, state) => const FoundationsScreen(),
        ),
    ],
  );
});

StatefulShellBranch _branch(AppDestination d, Widget screen) =>
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: d.path,
          pageBuilder: (context, state) => NoTransitionPage(child: screen),
        ),
      ],
    );
