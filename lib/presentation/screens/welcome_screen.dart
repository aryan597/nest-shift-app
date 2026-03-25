import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/premium_container.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: PremiumContainer(
                  height: 120,
                  width: 120,
                  isActive: true,
                  child: const Center(
                    child: Icon(Icons.home_repair_service, size: 48, color: AppTheme.primaryGold),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'NestShift',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your Home. Now Intelligent.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PremiumContainer(
                isActive: true,
                onTap: () => context.push('/pairing'),
                height: 60,
                child: Center(
                  child: Text(
                    'Setup Hardware',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
