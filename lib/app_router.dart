import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/secure_storage.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/login_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/insights/insights_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/pairing/pairing_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _publicPaths = [
  '/onboarding/splash',
  '/onboarding/welcome',
  '/onboarding/login',
  '/pairing',
  '/dashboard',
  '/insights',
  '/settings',
  '/',
];

class _RedirectNotifier extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void markInitialized() {
    _isInitialized = true;
    notifyListeners();
  }
}

final _redirectNotifier = _RedirectNotifier();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding/splash',
    redirect: (context, state) async {
      if (!_redirectNotifier.isInitialized) {
        await SecureStorageService.instance.init();
        _redirectNotifier.markInitialized();
      }

      final path = state.uri.toString();
      if (_publicPaths.contains(path)) return null;

      final isOnboardingComplete = await SecureStorageService.instance.isOnboardingComplete();
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      final token = await SecureStorageService.instance.getToken();

      if (!isOnboardingComplete) return '/onboarding/welcome';

      if (isOnboardingComplete && token == null && !isDemoMode) {
        return '/onboarding/login';
      }

      return null;
    },
    routes: [
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
        path: '/onboarding/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/pairing',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const PairingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) async {
          final isOnboardingComplete = await SecureStorageService.instance.isOnboardingComplete();
          final isDemoMode = await SecureStorageService.instance.isDemoMode();
          final token = await SecureStorageService.instance.getToken();
          
          if (!isOnboardingComplete) return '/onboarding/welcome';
          if (token == null && !isDemoMode) return '/onboarding/login';
          return '/dashboard';
        },
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: DashboardScreen(),
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