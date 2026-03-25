import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'skeuomorphic_container.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceBase,
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: AppTheme.primaryStatusOn.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ]
              : AppTheme.skeuomorphicOutset,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isListening
                ? [
                    AppTheme.shadowDark.withOpacity(0.8),
                    AppTheme.shadowLight.withOpacity(0.1),
                  ]
                : [
                    AppTheme.shadowLight.withOpacity(0.4),
                    AppTheme.shadowDark.withOpacity(0.4),
                  ],
          ),
        ),
        child: Center(
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening ? AppTheme.primaryStatusOn : Colors.white70,
            size: 36,
          )
          .animate(target: isListening ? 1 : 0)
          .shimmer(duration: 1000.ms, color: Colors.white, size: 2)
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms, curve: Curves.easeOut),
        ),
      ),
    );
  }
}
