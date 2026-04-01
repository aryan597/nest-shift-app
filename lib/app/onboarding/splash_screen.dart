import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateNext();
    });
  }

  Future<void> _navigateNext() async {
    if (_isNavigating) return;
    _isNavigating = true;

    // Wait 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      await SecureStorageService.instance.init();
      final isOnboardingComplete = await SecureStorageService.instance.isOnboardingComplete();

      if (!mounted) return;

      if (isOnboardingComplete) {
        // Check if user has a token or is in demo mode - go to dashboard
        final token = await SecureStorageService.instance.getToken();
        final isDemoMode = await SecureStorageService.instance.isDemoMode();
        
        if (token != null || isDemoMode) {
          context.go('/dashboard');
        } else {
          context.go('/onboarding/login');
        }
      } else {
        context.go('/onboarding/welcome');
      }
    } catch (e) {
      // If there's an error, just go to welcome
      if (mounted) {
        context.go('/onboarding/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 24),
              // Wordmark
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'NEST',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 36,
                        letterSpacing: 2,
                      ),
                    ),
                    TextSpan(
                      text: 'SHIFT',
                      style: AppTypography.displayLarge.copyWith(
                        fontSize: 36,
                        letterSpacing: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms),
              const SizedBox(height: 8),
              Text(
                'Your home. Your data. Your control.',
                style: AppTypography.bodySmall,
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              const SizedBox(height: 60),
              // Pulsing dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 1000.ms,
                        delay: Duration(milliseconds: index * 200),
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(0.8, 0.8),
                        duration: 1000.ms,
                      );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
