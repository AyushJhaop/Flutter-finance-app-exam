import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/main/main_shell.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import '../../screens/transactions/transactions_screen.dart';
import '../../screens/analytics/analytics_screen.dart';
import '../../screens/savings/savings_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/accounts/accounts_screen.dart';
import '../../screens/budgets/budgets_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/security/security_screen.dart';
import '../../screens/premium/premium_screen.dart';

/// Route names — use these constants everywhere instead of string literals.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String dashboard = '/main/dashboard';
  static const String transactions = '/main/transactions';
  static const String analytics = '/main/analytics';
  static const String savings = '/main/savings';
  static const String profile = '/main/profile';
  static const String accounts = '/main/accounts';
  static const String budgets = '/main/budgets';
  static const String notifications = '/main/notifications';
  static const String report = '/main/report';
  static const String security = '/main/security';
  static const String premium = '/main/premium';
}

/// AppRouter — centralised navigation configuration.
/// Uses go_router with redirect-based auth guard.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authProvider,
      debugLogDiagnostics: false,
      redirect: (ctx, state) => _redirect(ctx, state, authProvider),
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: 'splash',
          builder: (context, _) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: 'onboarding',
          builder: (context, _) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, _) => const LoginScreen(),
          routes: [
            GoRoute(
              path: 'signup',
              name: 'signup',
              builder: (context, _) => const SignupScreen(),
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              name: 'dashboard',
              builder: (context, _) => const DashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.transactions,
              name: 'transactions',
              builder: (context, _) => const TransactionsScreen(),
            ),
            GoRoute(
              path: AppRoutes.analytics,
              name: 'analytics',
              builder: (context, _) => const AnalyticsScreen(),
            ),
            GoRoute(
              path: AppRoutes.savings,
              name: 'savings',
              builder: (context, _) => const SavingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              name: 'profile',
              builder: (context, _) => const ProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.accounts,
              name: 'accounts',
              builder: (context, _) => const AccountsScreen(),
            ),
            GoRoute(
              path: AppRoutes.budgets,
              name: 'budgets',
              builder: (context, _) => const BudgetsScreen(),
            ),
            GoRoute(
              path: AppRoutes.notifications,
              name: 'notifications',
              builder: (context, _) => const NotificationsScreen(),
            ),
            GoRoute(
              path: AppRoutes.report,
              name: 'report',
              builder: (context, _) => const ReportsScreen(),
            ),
            GoRoute(
              path: AppRoutes.security,
              name: 'security',
              builder: (context, _) => const SecurityScreen(),
            ),
            GoRoute(
              path: AppRoutes.premium,
              name: 'premium',
              builder: (context, _) => const PremiumScreen(),
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(
    BuildContext context,
    GoRouterState state,
    AuthProvider authProvider,
  ) {
    final status = authProvider.status;
    final loc = state.matchedLocation;

    // Still initializing — stay on splash
    if (status == AuthStatus.initial) {
      if (loc == AppRoutes.splash) return null;
      return AppRoutes.splash;
    }

    final isOnAuth = loc == AppRoutes.login ||
        loc == '/login/signup' ||
        loc == AppRoutes.onboarding;

    if (status == AuthStatus.unauthenticated &&
        !isOnAuth &&
        loc != AppRoutes.splash) {
      return AppRoutes.login;
    }

    if (status == AuthStatus.authenticated && isOnAuth) {
      return AppRoutes.dashboard;
    }

    return null;
  }
}
