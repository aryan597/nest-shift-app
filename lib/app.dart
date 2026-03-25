import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/pairing/pairing_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/insights/insights_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final token = await SecureStorageService.instance.getToken();
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      final isAuthenticated = token != null || isDemoMode;

      final isOnPairing = state.uri.toString() == '/pairing';

      if (!isAuthenticated && !isOnPairing) return '/pairing';
      if (isAuthenticated && isOnPairing) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) async {
          final token = await SecureStorageService.instance.getToken();
          final isDemoMode = await SecureStorageService.instance.isDemoMode();
          return (token != null || isDemoMode) ? '/dashboard' : '/pairing';
        },
      ),
      GoRoute(
        path: '/pairing',
        pageBuilder: (context, state) => const NoTransitionPage(child: PairingScreen()),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
      ),
      GoRoute(
        path: '/insights',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const InsightsScreen(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        ),
      ),
    ],
  );
});

class NestShiftApp extends ConsumerWidget {
  const NestShiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);
    return MaterialApp.router(
      title: 'NestShift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
