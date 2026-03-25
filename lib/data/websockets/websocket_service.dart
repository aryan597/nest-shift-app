import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/secure_storage_service.dart';
import '../../core/constants/app_constants.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(ref);
});

class WebSocketService {
  final Ref _ref;
  WebSocketChannel? _channel;
  
  WebSocketService(this._ref);

  Future<void> connect() async {
    final storage = _ref.read(secureStorageProvider);
    final ip = await storage.getDeviceIp();
    final port = await storage.getDevicePort();
    
    String wsUrl = AppConstants.defaultWebSocketUrl;
    if (ip != null && port != null) {
      wsUrl = 'ws://$ip:$port/ws';
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel?.stream.listen((message) {
        // Handle incoming messages
        _handleMessage(message);
      }, onDone: () {
        // Handle reconnect logic
      }, onError: (error) {
        // Handle error
      });
    } catch (e) {
      // Connecting failed
    }
  }

  void _handleMessage(dynamic message) {
    if (message is String) {
      final data = jsonDecode(message);
      // Further routing of messages to state providers
    }
  }

  void sendCommand(Map<String, dynamic> command) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(command));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
