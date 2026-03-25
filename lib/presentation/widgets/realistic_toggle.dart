import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import 'skeuomorphic_container.dart';

class RealisticToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const RealisticToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: SizedBox(
        width: 70,
        height: 36,
        child: Stack(
          children: [
            // Background Track (Inset)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: AppTheme.backgroundBase,
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    offset: Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            
            // LED Indicator line
            Positioned(
              top: 17,
              left: 14,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 2,
                decoration: BoxDecoration(
                  color: value ? AppTheme.primaryStatusOn : Colors.grey.withOpacity(0.3),
                  boxShadow: value ? [
                    BoxShadow(
                      color: AppTheme.primaryStatusOn.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ] : [],
                ),
              ),
            ),

            Positioned(
              top: 17,
              right: 14,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 2,
                decoration: BoxDecoration(
                  color: !value ? AppTheme.primaryStatusOff : Colors.grey.withOpacity(0.3),
                  boxShadow: !value ? [
                    BoxShadow(
                      color: AppTheme.primaryStatusOff.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    )
                  ] : [],
                ),
              ),
            ),

            // Toggle Knob
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutBack,
              left: value ? 34 : 2,
              top: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceBase,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.shadowLight.withOpacity(0.8),
                      AppTheme.shadowDark.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 3),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.shadowDark,
                          AppTheme.shadowLight,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
