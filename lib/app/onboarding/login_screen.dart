import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Go back to welcome
        if (context.mounted) {
          context.go('/onboarding/welcome');
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 32),
                  Text(
                    'NestShift',
                    style: AppTypography.displayMedium,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                  const Spacer(flex: 2),
                  // Sign in with Google button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        // TODO: Implement Google Auth
                        // For now, just show a message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google Auth coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('Sign in with Google'),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                  const SizedBox(height: 16),
                    // Skip button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        // Skip login - go to scan QR code
                        await SecureStorageService.instance.setOnboardingComplete(true);
                        if (context.mounted) {
                          context.go('/pairing');
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Skip & Scan QR Code'),
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
                  const SizedBox(height: 24),
                  // Demo mode option
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Development Mode',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try the app with demo data',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await SecureStorageService.instance.setOnboardingComplete(true);
                              await SecureStorageService.instance.setDemoMode(true);
                              if (context.mounted) {
                                context.go('/dashboard');
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              side: const BorderSide(color: AppColors.accent),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Enter Demo Mode'),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
                  const Spacer(flex: 3),
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
