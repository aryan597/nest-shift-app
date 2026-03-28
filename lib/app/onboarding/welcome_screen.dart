import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Exit Setup?', style: TextStyle(color: AppColors.textPrimary)),
            content: const Text('Are you sure you want to exit the setup?', style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit == true && context.mounted) {
          await SecureStorageService.instance.setOnboardingComplete(false);
          if (context.mounted) {
            context.go('/onboarding/splash');
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Colorful background orbs
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.purple.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.25),
                      AppColors.blue.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.pink.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Glassmorphism House icon
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.accent.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.home_work_rounded,
                            size: 70,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          Positioned(
                            top: 35,
                            left: 35,
                            child: Container(
                              width: 25,
                              height: 35,
                              decoration: BoxDecoration(
                                color: AppColors.accentWarm.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 35,
                            right: 35,
                            child: Container(
                              width: 25,
                              height: 35,
                              decoration: BoxDecoration(
                                color: AppColors.accentWarm.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 35,
                            child: Icon(
                              Icons.wifi_rounded,
                              size: 28,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.elasticOut)
                        .fadeIn(duration: 600.ms),
                    const Spacer(flex: 1),
                    // Glassmorphism card with text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceRaised.withValues(alpha: 0.7),
                            AppColors.surface.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.glassBorder,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to NestShift',
                            style: AppTypography.displayMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Privacy-first home automation. No cloud. No subscriptions. Just your Pi.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Demo Mode button - Vibrant gradient
                          GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              await SecureStorageService.instance.setOnboardingComplete(true);
                              await SecureStorageService.instance.setDemoMode(true);
                              if (context.mounted) {
                                context.go('/dashboard');
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_circle_outline, color: Colors.white, size: 26),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Try Demo Mode',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Connect to Hub button - Glass style
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context.go('/pairing');
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code_scanner_rounded, color: AppColors.textSecondary, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Connect to Hub',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0, delay: 300.ms, duration: 600.ms),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
