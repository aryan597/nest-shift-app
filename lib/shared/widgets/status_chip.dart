import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum StatusChipVariant { online, offline, active, idle }

class StatusChip extends StatefulWidget {
  final StatusChipVariant variant;
  final String label;

  const StatusChip({super.key, required this.variant, required this.label});

  const StatusChip.online({super.key, required this.label}) : variant = StatusChipVariant.online;
  const StatusChip.offline({super.key, required this.label}) : variant = StatusChipVariant.offline;
  const StatusChip.active({super.key, required this.label}) : variant = StatusChipVariant.active;
  const StatusChip.idle({super.key, required this.label}) : variant = StatusChipVariant.idle;

  @override
  State<StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<StatusChip> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startPulse();
  }

  void _startPulse() {
    if (widget.variant == StatusChipVariant.online || widget.variant == StatusChipVariant.active) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StatusChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variant != widget.variant) _startPulse();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.variant) {
      case StatusChipVariant.online:
        return AppColors.success;
      case StatusChipVariant.offline:
        return AppColors.warning;
      case StatusChipVariant.active:
        return AppColors.primary;
      case StatusChipVariant.idle:
        return AppColors.textMuted;
    }
  }

  Color get _bgColor {
    switch (widget.variant) {
      case StatusChipVariant.online:
        return AppColors.success.withValues(alpha: 0.08);
      case StatusChipVariant.offline:
        return AppColors.warning.withValues(alpha: 0.08);
      case StatusChipVariant.active:
        return AppColors.primary.withValues(alpha: 0.08);
      case StatusChipVariant.idle:
        return AppColors.textMuted.withValues(alpha: 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _dotColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _dotColor.withValues(alpha: _pulseAnimation.value),
                boxShadow: [
                  BoxShadow(color: _dotColor.withValues(alpha: 0.5 * _pulseAnimation.value), blurRadius: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.label,
            style: AppTypography.exo(fontSize: 11, fontWeight: FontWeight.w600, color: _dotColor),
          ),
        ],
      ),
    );
  }
}
