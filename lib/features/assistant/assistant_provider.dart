import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/websocket_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/models/chat_message.dart';

class AssistantState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String sessionId;

  const AssistantState({
    required this.messages,
    required this.isSending,
    required this.sessionId,
  });

  AssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? sessionId,
  }) =>
      AssistantState(
        messages: messages ?? this.messages,
        isSending: isSending ?? this.isSending,
        sessionId: sessionId ?? this.sessionId,
      );
}

class AssistantNotifier extends AsyncNotifier<AssistantState> {
  StreamSubscription? _wsSub;
  final _uuid = const Uuid();

  @override
  Future<AssistantState> build() async {
    final sessionId = _uuid.v4();
    final isDemoMode = await SecureStorageService.instance.isDemoMode();

    if (isDemoMode) {
      return AssistantState(
        messages: _demoMessages(),
        isSending: false,
        sessionId: sessionId,
      );
    }

    _listenToWebSocket();
    ref.onDispose(() => _wsSub?.cancel());

    final messages = await _loadHistory();
    return AssistantState(messages: messages, isSending: false, sessionId: sessionId);
  }

  List<ChatMessage> _demoMessages() => [
        ChatMessage.ai(text: 'Hello! I\'m the NestShift Brain. I can control your devices, set scenes, and answer questions about your home.'),
        ChatMessage.user('Turn on the living room light'),
        ChatMessage.ai(text: 'Done! I\'ve turned on the living room light.', devicesAffected: ['d1']),
      ];

  Future<List<ChatMessage>> _loadHistory() async {
    try {
      final dio = await BrainDioClient.instance.dio;
      final response = await dio.get(ApiEndpoints.aiHistory);
      final list = response.data as List<dynamic>;
      return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  void _listenToWebSocket() {
    _wsSub?.cancel();
    _wsSub = BrainWebSocketService.instance.eventStream.listen((event) {
      if (event['type'] == 'ai_response') {
        final data = event as Map<String, dynamic>?;
        if (data != null) {
          final current = state.value;
          if (current == null) return;
          final msgs = current.messages.where((m) => !m.isTypingIndicator).toList();
          msgs.add(ChatMessage.ai(
            text: data['message'] as String? ?? '',
            devicesAffected: (data['devices_affected'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          ));
          state = AsyncData(current.copyWith(messages: msgs, isSending: false));
        }
      }
    });
  }

  Future<void> sendCommand(String text) async {
    final current = state.value;
    if (current == null || text.trim().isEmpty) return;

    final msgs = [...current.messages, ChatMessage.user(text), ChatMessage.typing()];
    state = AsyncData(current.copyWith(messages: msgs, isSending: true));

    try {
      final isDemoMode = await SecureStorageService.instance.isDemoMode();
      if (isDemoMode) {
        await Future.delayed(const Duration(milliseconds: 800));
        final s = state.value!;
        final updated = s.messages.where((m) => !m.isTypingIndicator).toList();
        updated.add(ChatMessage.ai(text: 'Sure! In demo mode I\'m not connected to a real hub, but I understand your command: "$text".'));
        state = AsyncData(s.copyWith(messages: updated, isSending: false));
        return;
      }

      final dio = await BrainDioClient.instance.dio;
      final response = await dio.post(ApiEndpoints.aiCommand, data: {
        'text': text,
        'session_id': current.sessionId,
      });
      final data = response.data as Map<String, dynamic>;
      final s = state.value!;
      final updated = s.messages.where((m) => !m.isTypingIndicator).toList();
      updated.add(ChatMessage.ai(
        text: data['message'] as String? ?? '',
        devicesAffected: (data['devices_affected'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ));
      state = AsyncData(s.copyWith(messages: updated, isSending: false));
    } catch (e) {
      final s = state.value;
      if (s != null) {
        final updated = s.messages.where((m) => !m.isTypingIndicator).toList();
        updated.add(ChatMessage.ai(text: 'Sorry, I couldn\'t process that. Please check your hub connection.'));
        state = AsyncData(s.copyWith(messages: updated, isSending: false));
      }
    }
  }
}

final assistantProvider = AsyncNotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);
