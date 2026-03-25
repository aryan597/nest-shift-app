import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/models/device_model.dart';
import '../../domain/models/room_model.dart';

final dummyDataServiceProvider = Provider<DummyDataService>((ref) {
  return DummyDataService();
});

class DummyDataService {
  List<DeviceModel> getDummyDevices() {
    return [
      DeviceModel(id: '1', name: 'Main Light', room: 'Living Room', type: 'light', isOn: true),
      DeviceModel(id: '2', name: 'Ambient LED', room: 'Living Room', type: 'light', isOn: false),
      DeviceModel(id: '3', name: 'AC Unit', room: 'Living Room', type: 'climate', isOn: true),
      DeviceModel(id: '4', name: 'Desk Lamp', room: 'Office', type: 'light', isOn: true),
      DeviceModel(id: '5', name: 'PC Power', room: 'Office', type: 'relay', isOn: true),
    ];
  }

  List<RoomModel> getDummyRooms() {
    return [
      RoomModel(id: 'r1', name: 'Living Room', deviceCount: 3, temperature: '22°'),
      RoomModel(id: 'r2', name: 'Office', deviceCount: 2, temperature: '24°'),
      RoomModel(id: 'r3', name: 'Bedroom', deviceCount: 4, temperature: '20°'),
      RoomModel(id: 'r4', name: 'Kitchen', deviceCount: 5, temperature: '21°'),
    ];
  }

  List<FlSpot> getDummyEnergyData() {
    return const [
      FlSpot(0, 1500),
      FlSpot(4, 1200),
      FlSpot(8, 2500),
      FlSpot(12, 1800),
      FlSpot(16, 3200),
      FlSpot(20, 2900),
      FlSpot(24, 1600),
    ];
  }
  
  String getDummyAiResponse() {
    return "I've turned off the lights in the Living Room and set the AC to Eco mode. Is there anything else you need?";
  }
}
