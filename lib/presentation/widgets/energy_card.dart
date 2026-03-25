import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'premium_container.dart';

class EnergyCard extends StatelessWidget {
  final String title;
  final double currentUsageWatts;
  final double maxUsageWatts;

  const EnergyCard({
    super.key,
    required this.title,
    required this.currentUsageWatts,
    this.maxUsageWatts = 5000,
  });

  @override
  Widget build(BuildContext context) {
    double usagePercentage = (currentUsageWatts / maxUsageWatts).clamp(0.0, 1.0);
    
    return PremiumContainer(
      height: 170,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.electric_bolt, color: AppTheme.primaryGold),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${currentUsageWatts.round()}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryGold,
                  height: 1,
                  shadows: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.3),
                      blurRadius: 15,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 8),
                child: Text('Watts', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white54)),
              ),
            ],
          ),
          const Spacer(),
          // Glowing Meter Bar setup
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: usagePercentage,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: AppTheme.primaryGold,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
