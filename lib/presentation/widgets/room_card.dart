import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'premium_container.dart';

class RoomCard extends StatelessWidget {
  final String title;
  final int deviceCount;
  final int activeCount;
  final VoidCallback onTap;
  final String temperature;

  const RoomCard({
    super.key,
    required this.title,
    required this.deviceCount,
    required this.activeCount,
    required this.onTap,
    this.temperature = '--°',
  });

  @override
  Widget build(BuildContext context) {
    bool isActive = activeCount > 0;
    
    return PremiumContainer(
      onTap: onTap,
      isActive: isActive,
      height: 130,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppTheme.primaryGold : Colors.white24,
                      boxShadow: isActive ? [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.5),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ] : [],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isActive ? '$activeCount Active' : 'All Off',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isActive ? AppTheme.primaryGold : Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temperature,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.thermostat, color: Colors.white38, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
