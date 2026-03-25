import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/room_model.dart';
import '../../services/dummy_data_service.dart';

// Providers for dashboard state
final roomsProvider = FutureProvider<List<RoomModel>>((ref) async {
  // In a real app we'd fetch from DeviceRepository via Dio or Websocket
  // For now, load dummy data
  final dummyService = ref.read(dummyDataServiceProvider);
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
  return dummyService.getDummyRooms();
});

final totalEnergyUsageProvider = Provider<double>((ref) {
  return 1250.0; // Dummy value for current W usage
});
