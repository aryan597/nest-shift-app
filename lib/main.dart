import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/storage/secure_storage.dart';
import 'features/pairing/pairing_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/insights/insights_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI to match app theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Pre-load Google Fonts (speeds up first render)
  await GoogleFonts.pendingFonts([
    GoogleFonts.orbitron(),
    GoogleFonts.exo2(),
    GoogleFonts.jetBrainsMono(),
  ]);

  runApp(const ProviderScope(child: NestShiftApp()));
}

class NestShiftApp extends ConsumerWidget {
  const NestShiftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'NestShift',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: _buildRouter(),
    );
  }

  GoRouter _buildRouter() => GoRouter(
        initialLocation: '/',
        redirect: (context, state) async {
          final token = await SecureStorageService.instance.getToken();
          final isDemoMode = await SecureStorageService.instance.isDemoMode();
          final isAuthenticated = token != null || isDemoMode;
          final path = state.uri.toString();

          if (!isAuthenticated && path != '/pairing') return '/pairing';
          if (isAuthenticated && path == '/pairing') return '/dashboard';
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
            pageBuilder: (_, state) => const NoTransitionPage(child: PairingScreen()),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/insights',
            pageBuilder: (_, state) => CustomTransitionPage(
              child: const InsightsScreen(),
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
          ),
        ],
      );
}
