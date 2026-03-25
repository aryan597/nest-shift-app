import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/device.dart';
import '../../../shared/widgets/nest_panel.dart';
import '../../../shared/widgets/status_chip.dart';

class SensorCard extends StatelessWidget {
  final Device device;

  const SensorCard({super.key, required this.device});

  IconData get _icon {
    switch (device.type) {
      case 'sensor':
        if (device.name.toLowerCase().contains('temp')) return Icons.thermostat_rounded;
        if (device.name.toLowerCase().contains('door')) return Icons.door_front_door_rounded;
        if (device.name.toLowerCase().contains('motion')) return Icons.motion_photos_on_rounded;
        if (device.name.toLowerCase().contains('humid')) return Icons.water_drop_rounded;
        return Icons.sensors_rounded;
      default:
        return Icons.sensors_rounded;
    }
  }

  String get _valueDisplay {
    // In real implementation this comes from device.state extras
    if (device.name.toLowerCase().contains('temp')) return '24.3°C';
    if (device.name.toLowerCase().contains('door')) return device.state.on ? 'OPEN' : 'CLOSED';
    if (device.name.toLowerCase().contains('motion')) return device.state.on ? 'DETECTED' : 'CLEAR';
    if (device.name.toLowerCase().contains('humid')) return '62%';
    return device.state.on ? 'ACTIVE' : 'IDLE';
  }

  String _formatLastSeen(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return NestPanel(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.raised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(_icon, size: 22, color: device.online ? AppColors.primary : AppColors.textMuted),
            ),
            const SizedBox(width: 14),
            // Name + room
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: AppTypography.exo(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text(device.room, style: AppTypography.labelSmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated ${_formatLastSeen(device.lastSeen)}',
                    style: AppTypography.mono(fontSize: 9, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Value + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _valueDisplay,
                  style: AppTypography.mono(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: device.online ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                StatusChip(
                  variant: device.online ? StatusChipVariant.active : StatusChipVariant.offline,
                  label: device.online ? 'Active' : 'Offline',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
