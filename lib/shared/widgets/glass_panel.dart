import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final bool showGlow;
  final Color? glowColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.08,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.showGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final glow = glowColor ?? AppColors.primary;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showGlow ? [
          BoxShadow(
            color: glow.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: opacity * 1.5),
                  Colors.white.withValues(alpha: opacity * 0.5),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Gradient glass panel with vibrant colors
class GradientGlassPanel extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool showGlow;
  final Color? glowColor;

  const GradientGlassPanel({
    super.key,
    required this.child,
    this.gradientColors,
    this.padding,
    this.borderRadius,
    this.showGlow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final colors = gradientColors ?? AppColors.gradientGlass;
    final glow = glowColor ?? AppColors.primary;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: showGlow ? [
          BoxShadow(
            color: glow.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[0].withValues(alpha: 0.15),
                  colors[1].withValues(alpha: 0.1),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: AppColors.glassBorderLight,
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Neon glow card for active states
class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const NeonCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.glowIntensity = 0.3,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: radius,
          border: Border.all(
            color: glowColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
