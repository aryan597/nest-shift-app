import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ConnectionBanner extends StatefulWidget {
  final bool isVisible;
  const ConnectionBanner({super.key, required this.isVisible});

  @override
  State<ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<ConnectionBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.isVisible ? 38 : 0,
      child: widget.isVisible
          ? AnimatedBuilder(
              animation: _shimmerController,
              builder: (_, __) {
                final shimmerValue = _shimmerController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(shimmerValue * 2 - 1, 0),
                      end: Alignment(shimmerValue * 2, 0),
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withValues(alpha: 0.7),
                        AppColors.accent,
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reconnecting to hub...',
                        style: AppTypography.exo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }
}
