import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Custom metallic toggle switch — 72x38dp (large) or 52x28dp (small)
class MetallicToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool small;

  const MetallicToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.small = false,
  });

  @override
  State<MetallicToggle> createState() => _MetallicToggleState();
}

class _MetallicToggleState extends State<MetallicToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(MetallicToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _controller.animateTo(1.0, curve: Curves.elasticOut, duration: const Duration(milliseconds: 380));
      } else {
        _controller.animateTo(0.0, curve: Curves.elasticOut, duration: const Duration(milliseconds: 380));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onChanged == null) return;
    HapticFeedback.mediumImpact();
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final trackW = widget.small ? 52.0 : 72.0;
    final trackH = widget.small ? 28.0 : 38.0;
    final thumbSize = widget.small ? 22.0 : 30.0;
    final dotSize = widget.small ? 6.0 : 8.0;
    final padding = (trackH - thumbSize) / 2;
    final travelDistance = trackW - thumbSize - padding * 2;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = _slideAnim.value;
          return Container(
            width: trackW,
            height: trackH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(trackH / 2),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF080C14),
                  const Color(0xFF0E1626),
                ],
              ),
              border: Border.all(
                color: widget.value
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Track fill glow when ON
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: t,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(trackH / 2),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: padding + (travelDistance * t),
                  top: padding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2E3E58),
                          Color(0xFF1A2436),
                          Color(0xFF0F1828),
                        ],
                      ),
                      border: Border.all(
                        color: widget.value
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : const Color(0xFF253040),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                          spreadRadius: 1,
                        ),
                        if (widget.value)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35 * t),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.value ? AppColors.primary : const Color(0xFF1A2236),
                          boxShadow: widget.value
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [
                                  const BoxShadow(
                                    color: Colors.black54,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
