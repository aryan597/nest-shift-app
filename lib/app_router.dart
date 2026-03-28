import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/secure_storage.dart';
import 'features/pairing/pairing_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/settings/settings_screen.dart';
import 'app/onboarding/splash_screen.dart';
import 'app/onboarding/welcome_screen.dart';
import 'app/onboarding/feature_tour_screen.dart';
import 'app/onboarding/login_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// List of onboarding paths that should be allowed to proceed
final _onboardingPaths = [
  '/onboarding/splash',
  '/onboarding/welcome',
  '/onboarding/feature-tour',
  '/onboarding/login',
  '/pairing',
  '/dashboard',
  '/',
];

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      await SecureStorageService.instance.init();
      
      final isOnboardingComplete = await SecureStorageService.instance.isOnboardingComplete();
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      final token = await SecureStorageService.instance.getToken();
      final path = state.uri.toString();

      // If currently on an onboarding path, allow it to proceed
      if (_onboardingPaths.contains(path)) {
        return null;
      }

      // If onboarding not complete, go to splash
      if (!isOnboardingComplete) {
        return '/onboarding/splash';
      }

      // If onboarding complete but not logged in (no token and no demo), go to login
      if (isOnboardingComplete && token == null && !isDemoMode) {
        return '/onboarding/login';
      }

      // If trying to access onboarding/login while already authenticated
      if (isOnboardingComplete && (token != null || isDemoMode)) {
        if (path.startsWith('/onboarding')) {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      // Onboarding Routes
      GoRoute(
        path: '/onboarding/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/onboarding/feature-tour',
        pageBuilder: (context, state) {
          final skipLogin = state.uri.queryParameters['skipLogin'] == 'true';
          return CustomTransitionPage(
            child: FeatureTourScreen(skipLogin: skipLogin),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/onboarding/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Main App Routes
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          final isOnboardingComplete = await SecureStorageService.instance.isOnboardingComplete();
          final isDemoMode = await SecureStorageService.instance.isDemoMode();
          final token = await SecureStorageService.instance.getToken();
          
          if (!isOnboardingComplete) return '/onboarding/splash';
          if (token == null && !isDemoMode) return '/onboarding/login';
          return '/dashboard';
        },
      ),
      GoRoute(
        path: '/pairing',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const PairingScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/insights',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const InsightsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
