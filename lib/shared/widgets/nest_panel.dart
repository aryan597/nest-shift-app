import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NestPanel extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const NestPanel({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
