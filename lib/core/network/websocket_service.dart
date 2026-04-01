import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/secure_storage.dart';
import '../constants/app_constants.dart';
import 'api_endpoints.dart';

enum WsConnectionState { disconnected, connecting, connected }

typedef WsEventCallback = void Function(String eventType, Map<String, dynamic> data);

class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  WsConnectionState _state = WsConnectionState.disconnected;
  WsConnectionState get state => _state;

  int _reconnectAttempts = 0;
  static const List<int> _backoffSeconds = [1, 2, 4, 8, 16, 30];

  final _stateController = StreamController<WsConnectionState>.broadcast();
  Stream<WsConnectionState> get connectionStream => _stateController.stream;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  bool _shouldReconnect = true;

  Future<void> connect() async {
    if (_state == WsConnectionState.connected || _state == WsConnectionState.connecting) {
      return;
    }
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    _setState(WsConnectionState.connecting);
    try {
      final info = await SecureStorageService.instance.getConnectionInfo();
      if (info == null) {
        _setState(WsConnectionState.disconnected);
        return;
      }
      final (ip, port) = info;
      final uri = Uri.parse('ws://$ip:$port/ws');
      debugPrint('[WS] Connecting to: $uri');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready.timeout(const Duration(seconds: 10));
      _setState(WsConnectionState.connected);
      _reconnectAttempts = 0;
      _startPing();

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      debugPrint('[WS] Connected to $uri');
    } catch (e) {
      debugPrint('[WS] Connect error: $e');
      _setState(WsConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      _eventController.add(data);
    } catch (e) {
      debugPrint('[WS] Parse error: $e');
    }
  }

  void _onError(dynamic error) {
    debugPrint('[WS] Error: $error');
    _setState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[WS] Connection closed');
    _setState(WsConnectionState.disconnected);
    _pingTimer?.cancel();
    if (_shouldReconnect) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    final delay = _backoffSeconds[_reconnectAttempts.clamp(0, _backoffSeconds.length - 1)];
    if (_reconnectAttempts < _backoffSeconds.length - 1) _reconnectAttempts++;
    debugPrint('[WS] Reconnecting in ${delay}s (attempt $_reconnectAttempts)');
    _reconnectTimer = Timer(Duration(seconds: delay), _connect);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_state == WsConnectionState.connected) {
        try {
          _channel?.sink.add(jsonEncode({'type': 'ping'}));
        } catch (_) {}
      }
    });
  }

  void _setState(WsConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _setState(WsConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
  }
}

class BrainWebSocketService {
  BrainWebSocketService._();
  static final BrainWebSocketService instance = BrainWebSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  WsConnectionState _state = WsConnectionState.disconnected;
  WsConnectionState get state => _state;

  final _stateController = StreamController<WsConnectionState>.broadcast();
  Stream<WsConnectionState> get connectionStream => _stateController.stream;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  bool _shouldReconnect = true;

  Future<void> connect() async {
    if (_state == WsConnectionState.connected || _state == WsConnectionState.connecting) {
      return;
    }
    _shouldReconnect = true;
    await _connect();
  }

  Future<void> _connect() async {
    _setState(WsConnectionState.connecting);
    try {
      final info = await SecureStorageService.instance.getConnectionInfo();
      if (info == null) {
        _setState(WsConnectionState.disconnected);
        return;
      }
      final (ip, _) = info;
      final uri = Uri.parse('ws://$ip:${AppConstants.brainPort}/ws');
      debugPrint('[BrainWS] Connecting to: $uri');
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready.timeout(const Duration(seconds: 10));
      _setState(WsConnectionState.connected);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      debugPrint('[BrainWS] Connected to $uri');
    } catch (e) {
      debugPrint('[BrainWS] Connect error: $e');
      _setState(WsConnectionState.disconnected);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      _eventController.add(data);
    } catch (e) {
      debugPrint('[BrainWS] Parse error: $e');
    }
  }

  void _onError(dynamic error) {
    debugPrint('[BrainWS] Error: $error');
    _setState(WsConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[BrainWS] Connection closed');
    _setState(WsConnectionState.disconnected);
    if (_shouldReconnect) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _connect);
  }

  void _setState(WsConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _subscription?.cancel();
    await _channel?.sink.close();
    _setState(WsConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _eventController.close();
  }
}
