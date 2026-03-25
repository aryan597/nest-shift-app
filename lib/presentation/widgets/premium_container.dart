import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PremiumContainer extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const PremiumContainer({
    super.key,
    required this.child,
    this.isActive = false,
    this.padding = const EdgeInsets.all(20),
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        height: height,
        padding: padding,
        decoration: isActive ? AppTheme.activePanelDecoration : AppTheme.panelDecoration,
        child: child,
      ),
    );
  }
}
