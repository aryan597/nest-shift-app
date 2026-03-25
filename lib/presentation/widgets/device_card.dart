import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'premium_container.dart';
import 'realistic_toggle.dart';

class DeviceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isOn;
  final ValueChanged<bool> onToggle;

  const DeviceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumContainer(
      height: 140,
      isActive: isOn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: isOn ? AppTheme.primaryGold : Colors.white54,
                size: 32,
              ),
              RealisticToggle(
                value: isOn,
                onChanged: onToggle,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isOn ? Colors.white : Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isOn ? AppTheme.primaryGold : Colors.white38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
