import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/ai_chat_bubble.dart';
import '../widgets/voice_button.dart';
import '../providers/ai_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiChatProvider.notifier).sendUserMessage(text.trim());
    _msgController.clear();
    _scrollToBottom();
  }

  void _toggleListening() async {
    if (_isListening) {
      setState(() => _isListening = false);
      _sendMessage("Turn off the living room lights and set the AC to eco mode."); // Simulated voice input
    } else {
      setState(() => _isListening = true);
      // Simulate listening for 3 seconds then stop
      await Future.delayed(const Duration(seconds: 3));
      if (mounted && _isListening) {
        _toggleListening();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('NestShift AI'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  String timeStr = '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}';
                  return AIChatBubble(
                    text: msg.text,
                    isUser: msg.isUser,
                    time: timeStr,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.surfaceBase,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundBase,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask NestShift...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  VoiceButton(
                    isListening: _isListening,
                    onTap: _toggleListening,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
