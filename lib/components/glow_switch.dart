import 'package:flutter/material.dart';
import '../theme/nestshift_colors.dart';

class GlowSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const GlowSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: value ? NestShiftColors.primary.withOpacity(0.2) : NestShiftColors.surfaceElevated,
              border: Border.all(
                color: value ? NestShiftColors.primary : const Color(0xFF2D3748),
                width: 2,
              ),
              boxShadow: [
                if (value)
                  BoxShadow(
                    color: NestShiftColors.primary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  left: value ? 30.0 : 4.0,
                  top: 4.0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? NestShiftColors.primary : NestShiftColors.textSecondary,
                      boxShadow: [
                        if (value)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (label != null) ...[
            const SizedBox(width: 12),
            Text(
              label!,
              style: TextStyle(
                color: value ? NestShiftColors.textPrimary : NestShiftColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
