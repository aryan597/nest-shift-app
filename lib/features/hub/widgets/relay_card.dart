import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/device.dart';
import '../../../shared/widgets/nest_panel.dart';
import 'metallic_toggle.dart';

class RelayCard extends StatelessWidget {
  final Device device;
  final ValueChanged<bool>? onToggle;

  const RelayCard({super.key, required this.device, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isOn = device.state.on;
    return NestPanel(
      glowColor: isOn ? AppColors.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Pin badge + name + LED dot
            Row(
              children: [
                // Pin badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.raised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'PIN ${device.gpioPin}',
                    style: AppTypography.mono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    device.name,
                    style: AppTypography.exo(fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // LED status dot
                _LedDot(isOn: isOn, isOnline: device.online),
              ],
            ),
            const SizedBox(height: 6),
            // Row 2: Room label + protocol
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(device.room, style: AppTypography.labelSmall),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.raised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    device.protocol.toUpperCase(),
                    style: AppTypography.mono(fontSize: 9, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Row 3: Toggle + state label
            Row(
              children: [
                MetallicToggle(
                  value: isOn,
                  onChanged: device.online ? onToggle : null,
                ),
                const SizedBox(width: 12),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: AppTypography.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOn ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                if (!device.online)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'OFFLINE',
                      style: AppTypography.mono(fontSize: 9, color: AppColors.warning),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedDot extends StatefulWidget {
  final bool isOn;
  final bool isOnline;
  const _LedDot({required this.isOn, required this.isOnline});

  @override
  State<_LedDot> createState() => _LedDotState();
}

class _LedDotState extends State<_LedDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isOn && widget.isOnline) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_LedDot old) {
    super.didUpdateWidget(old);
    if (widget.isOn && widget.isOnline) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isOn && widget.isOnline ? AppColors.success : AppColors.textMuted.withValues(alpha: 0.3);
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: widget.isOn ? _pulse.value : 0.3),
          boxShadow: widget.isOn && widget.isOnline
              ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.5 * _pulse.value), blurRadius: 8)]
              : null,
        ),
      ),
    );
  }
}
