import 'package:flutter/material.dart';
import '../theme/nestshift_colors.dart';

class NestPanel extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double borderRadius;
  final bool isPressed;
  final VoidCallback? onTap;

  const NestPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.glowColor,
    this.borderRadius = 16.0,
    this.isPressed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: NestShiftColors.surfaceElevated,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: glowColor != null ? glowColor! : Color(0xFF2D3748),
            width: glowColor != null ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (glowColor != null)
              BoxShadow(
                color: glowColor!.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            // Outer Brutalist Shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: isPressed ? const Offset(2, 2) : const Offset(6, 6),
              blurRadius: isPressed ? 4 : 8,
              spreadRadius: 0,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NestShiftColors.surfaceElevated.withOpacity(0.8),
              NestShiftColors.surface,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}
