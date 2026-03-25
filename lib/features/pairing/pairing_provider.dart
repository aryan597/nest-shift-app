import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';

enum PairingStatus { idle, scanning, connecting, success, error }

class PairingState {
  final PairingStatus status;
  final String? errorMessage;
  const PairingState({required this.status, this.errorMessage});
  PairingState copyWith({PairingStatus? status, String? errorMessage}) =>
      PairingState(status: status ?? this.status, errorMessage: errorMessage ?? this.errorMessage);
}

class PairingNotifier extends AsyncNotifier<PairingState> {
  @override
  Future<PairingState> build() async => const PairingState(status: PairingStatus.idle);

  /// Called when a QR code is successfully scanned
  Future<bool> handleQrData(String rawValue) async {
    state = const AsyncData(PairingState(status: PairingStatus.connecting));
    try {
      final json = jsonDecode(rawValue) as Map<String, dynamic>;
      if (!json.containsKey('ip') || !json.containsKey('pairing_code')) {
        state = const AsyncData(PairingState(status: PairingStatus.error, errorMessage: 'Invalid QR code — not a NestShift device'));
        return false;
      }
      final ip = json['ip'] as String;
      final port = (json['port'] as int?) ?? 8000;
      final code = json['pairing_code'] as String;
      return await _pair(ip: ip, port: port, pairingCode: code);
    } on FormatException {
      state = const AsyncData(PairingState(status: PairingStatus.error, errorMessage: 'Invalid QR code — not a NestShift device'));
      return false;
    }
  }

  /// Manual IP pairing
  Future<bool> pairManually({required String ip, required int port, required String pairingCode}) async {
    state = const AsyncData(PairingState(status: PairingStatus.connecting));
    return _pair(ip: ip, port: port, pairingCode: pairingCode);
  }

  Future<bool> _pair({required String ip, required int port, required String pairingCode}) async {
    try {
      await DioClient.instance.reinitialize(ip: ip, port: port);
      final dio = await DioClient.instance.dio;
      final response = await dio.post(ApiEndpoints.pair, data: {'pairing_code': pairingCode});
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final hubId = data['hub_id'] as String? ?? '';

      await SecureStorageService.instance.saveToken(token);
      await SecureStorageService.instance.saveHubId(hubId);
      await SecureStorageService.instance.saveConnectionInfo(ip: ip, port: port);
      await SecureStorageService.instance.setDemoMode(false);

      state = const AsyncData(PairingState(status: PairingStatus.success));
      return true;
    } catch (e) {
      debugPrint('[PairingProvider] Error: $e');
      final msg = e is Exception ? 'Could not connect to hub — check the IP and code' : 'Something went wrong';
      state = AsyncData(PairingState(status: PairingStatus.error, errorMessage: msg));
      return false;
    }
  }

  Future<void> activateDemoMode() async {
    await SecureStorageService.instance.setDemoMode(true);
    state = const AsyncData(PairingState(status: PairingStatus.success));
  }

  void reset() {
    state = const AsyncData(PairingState(status: PairingStatus.idle));
  }
}

final pairingProvider = AsyncNotifierProvider<PairingNotifier, PairingState>(PairingNotifier.new);
