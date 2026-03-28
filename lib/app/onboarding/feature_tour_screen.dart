import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';

class FeatureTourScreen extends StatefulWidget {
  final bool skipLogin;
  
  const FeatureTourScreen({super.key, this.skipLogin = false});

  @override
  State<FeatureTourScreen> createState() => _FeatureTourScreenState();
}

class _FeatureTourScreenState extends State<FeatureTourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<bool> _onWillPop() async {
    if (widget.skipLogin) {
      // If demo mode, go back to welcome
      context.go('/onboarding/welcome');
    } else {
      // If login flow, go back to login
      context.go('/onboarding/login');
    }
    return false;
  }

  final List<FeatureSlide> _slides = [
    FeatureSlide(
      icon: Icons.shield_rounded,
      title: 'Total Privacy',
      description: 'All data stays on your Pi. Zero cloud. Zero subscriptions. Your home, your data.',
      color: AppColors.success,
    ),
    FeatureSlide(
      icon: Icons.mic_rounded,
      title: 'Voice Control',
      description: 'Just talk to your home. Voice commands powered by local AI.',
      color: AppColors.accent,
    ),
    FeatureSlide(
      icon: Icons.bolt_rounded,
      title: 'Smart Automations',
      description: 'Sensors trigger lights and alerts. Create custom rules for your lifestyle.',
      color: AppColors.accentWarm,
    ),
    FeatureSlide(
      icon: Icons.insights_rounded,
      title: 'Live Insights',
      description: "See your home's heartbeat in real-time. Monitor energy, sensors, and more.",
      color: AppColors.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTour();
    }
  }

  void _finishTour() {
    HapticFeedback.mediumImpact();
    if (widget.skipLogin) {
      // Go to pairing in demo mode
      context.go('/pairing');
    } else {
      context.go('/onboarding/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background orbs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finishTour,
                    child: Text(
                      'Skip',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: slide.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                slide.icon,
                                size: 60,
                                color: slide.color,
                              ),
                            )
                                .animate()
                                .scale(duration: 600.ms, curve: Curves.elasticOut)
                                .fadeIn(duration: 400.ms),
                            const SizedBox(height: 48),
                            // Title
                            Text(
                              slide.title,
                              style: AppTypography.displayMedium,
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 16),
                            // Description
                            Text(
                              slide.description,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 300.ms, duration: 400.ms)
                                .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 400.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.primary
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class FeatureSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  FeatureSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
