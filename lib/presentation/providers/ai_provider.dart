import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/dummy_data_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage(this.text, this.isUser, this.timestamp);
}

class AiChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage("Hello. I am NestShift, your home intelligence. How can I help you today?", false, DateTime.now().subtract(const Duration(minutes: 5))),
    ];
  }

  Future<void> sendUserMessage(String text) async {
    state = [...state, ChatMessage(text, true, DateTime.now())];
    
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 2));
    
    final dummyService = ref.read(dummyDataServiceProvider);
    state = [...state, ChatMessage(dummyService.getDummyAiResponse(), false, DateTime.now())];
  }
}

final aiChatProvider = NotifierProvider<AiChatNotifier, List<ChatMessage>>(() {
  return AiChatNotifier();
});
