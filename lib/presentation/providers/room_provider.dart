import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/device_model.dart';
import '../../services/dummy_data_service.dart';

class DevicesNotifier extends AsyncNotifier<List<DeviceModel>> {
  @override
  Future<List<DeviceModel>> build() async {
    final dummyService = ref.read(dummyDataServiceProvider);
    await Future.delayed(const Duration(milliseconds: 300));
    return dummyService.getDummyDevices();
  }

  void toggleDevice(String id, bool val) {
    if (state.value != null) {
      final currentList = state.value!;
      final newList = currentList.map((d) {
        if (d.id == id) {
          return d.copyWith(isOn: val);
        }
        return d;
      }).toList();
      state = AsyncData(newList);
    }
  }
}

final devicesProvider = AsyncNotifierProvider<DevicesNotifier, List<DeviceModel>>(() {
  return DevicesNotifier();
});

final roomDevicesProvider = Provider.family<AsyncValue<List<DeviceModel>>, String>((ref, roomId) {
  final asyncDevices = ref.watch(devicesProvider);
  return asyncDevices.whenData((devices) {
    if (roomId == 'r1') return devices.where((d) => d.room == 'Living Room').toList();
    if (roomId == 'r2') return devices.where((d) => d.room == 'Office').toList();
    return devices;
  });
});
