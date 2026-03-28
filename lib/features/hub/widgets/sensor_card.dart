import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/device.dart';
import '../../../shared/widgets/nest_panel.dart';
import '../../../shared/widgets/glass_panel.dart';
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
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.raised.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_icon, size: 24, color: device.online ? AppColors.primary : AppColors.textMuted),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTypography.outfit(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(device.room, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Sync: ${_formatLastSeen(device.lastSeen)}',
                  style: AppTypography.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _valueDisplay,
                style: AppTypography.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: device.online ? AppColors.textPrimary : AppColors.textMuted,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              StatusChip(
                variant: device.online ? StatusChipVariant.active : StatusChipVariant.offline,
                label: device.online ? 'Healthy' : 'Sync Lost',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
