class DeviceModel {
  final String id;
  final String name;
  final String room;
  final String type; // light, climate, relay
  final bool isOn;

  DeviceModel({
    required this.id,
    required this.name,
    required this.room,
    required this.type,
    required this.isOn,
  });

  DeviceModel copyWith({bool? isOn}) {
    return DeviceModel(
      id: id,
      name: name,
      room: room,
      type: type,
      isOn: isOn ?? this.isOn,
    );
  }
}
