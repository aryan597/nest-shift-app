import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/device.dart';
import '../../../shared/widgets/nest_panel.dart';
import '../../../shared/widgets/glass_panel.dart';
import 'metallic_toggle.dart';

class RelayCard extends StatelessWidget {
  final Device device;
  final ValueChanged<bool>? onToggle;

  const RelayCard({super.key, required this.device, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isOn = device.state.on;
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.raised.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'GPIO ${device.gpioPin}',
                  style: AppTypography.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  device.name,
                  style: AppTypography.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _LedDot(isOn: isOn, isOnline: device.online),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(device.room, style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              MetallicToggle(
                value: isOn,
                onChanged: device.online ? onToggle : null,
              ),
              const SizedBox(width: 16),
              Text(
                isOn ? 'ACTIVE' : 'IDLE',
                style: AppTypography.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isOn ? AppColors.primary : AppColors.textMuted,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (!device.online)
                Text(
                  'OFFLINE',
                  style: AppTypography.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning),
                ),
            ],
          ),
        ],
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
