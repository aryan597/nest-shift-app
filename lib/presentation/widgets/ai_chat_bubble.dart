import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'skeuomorphic_container.dart';

class AIChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const AIChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: SkeuomorphicContainer(
        isPressed: isUser, // User messages can look pressed into the screen, AI messages pop out
        borderRadius: 20,
        geometry: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        baseColor: isUser ? AppTheme.backgroundBase : AppTheme.surfaceBase,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isUser ? Colors.white70 : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
