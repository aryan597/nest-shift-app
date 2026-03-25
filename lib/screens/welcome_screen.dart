import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/nestshift_colors.dart';
import 'hub_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NestShiftColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            // Brutalist Logo/Typography
            Center(
              child: Text(
                'N\nS',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  height: 0.85,
                  color: NestShiftColors.primary,
                  shadows: [
                    Shadow(color: NestShiftColors.primaryGlow, blurRadius: 40)
                  ]
                ),
              ).animate()
                .fade(duration: 800.ms, curve: Curves.easeOut)
                .scaleXY(begin: 0.8, end: 1.0, curve: Curves.easeOutBack),
            ),
            const SizedBox(height: 48),
            Text(
              'INTELLIGENCE\nIS PRIVATE.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ).animate().fade(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HubScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NestShiftColors.primary,
                  foregroundColor: NestShiftColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'INITIALIZE',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: NestShiftColors.background,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ).animate().fade(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }
}
