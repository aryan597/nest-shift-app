import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notifications', style: AppTypography.displayMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Stay updated with your smart home',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          // Demo notifications
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final notifications = [
                  {'title': 'Soil Moisture Alert', 'message': 'Your garden needs watering', 'time': '2 min ago', 'icon': Icons.water_drop, 'color': AppColors.accent},
                  {'title': 'Device Offline', 'message': 'Temperature sensor disconnected', 'time': '1 hour ago', 'icon': Icons.wifi_off, 'color': AppColors.warning},
                  {'title': 'Automation Triggered', 'message': 'Night mode activated', 'time': '3 hours ago', 'icon': Icons.nightlight, 'color': AppColors.primary},
                  {'title': 'System Update', 'message': 'Hub firmware updated successfully', 'time': '1 day ago', 'icon': Icons.system_update, 'color': AppColors.success},
                ];
                
                if (index >= notifications.length) return null;
                final notif = notifications[index];
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (notif['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif['title'] as String, style: AppTypography.labelLarge),
                            const SizedBox(height: 2),
                            Text(notif['message'] as String, style: AppTypography.bodySmall),
                          ],
                        ),
                      ),
                      Text(notif['time'] as String, style: AppTypography.labelSmall),
                    ],
                  ),
                );
              },
              childCount: 4,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
