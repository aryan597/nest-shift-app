import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SkeuomorphicContainer extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final double borderRadius;
  final EdgeInsets geometry;
  final double height;
  final double width;
  final Color baseColor;

  const SkeuomorphicContainer({
    super.key,
    required this.child,
    this.isPressed = false,
    this.borderRadius = 16.0,
    this.geometry = const EdgeInsets.all(16.0),
    this.height = double.infinity,
    this.width = double.infinity,
    this.baseColor = AppTheme.surfaceBase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height == double.infinity ? null : height,
      width: width == double.infinity ? null : width,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPressed
              ? [
                  AppTheme.shadowDark.withOpacity(0.8),
                  AppTheme.shadowLight.withOpacity(0.1),
                ] // Inset lighting
              : [
                  AppTheme.shadowLight.withOpacity(0.4),
                  AppTheme.shadowDark.withOpacity(0.4),
                ], // Outset lighting
        ),
        boxShadow: isPressed
            ? null // If pressed, no drop shadow
            : [
                BoxShadow(
                  color: AppTheme.shadowDark.withOpacity(0.9),
                  offset: const Offset(6, 6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: AppTheme.shadowLight.withOpacity(0.5),
                  offset: const Offset(-6, -6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Padding(
        padding: geometry,
        child: child,
      ),
    );
  }
}
