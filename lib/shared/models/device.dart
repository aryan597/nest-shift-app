class DeviceState {
  final bool on;
  const DeviceState({required this.on});
  factory DeviceState.fromJson(Map<String, dynamic> json) =>
      DeviceState(on: json['on'] as bool? ?? false);
  Map<String, dynamic> toJson() => {'on': on};
  DeviceState copyWith({bool? on}) => DeviceState(on: on ?? this.on);
}

class Device {
  final String id;
  final String name;
  final String type; // light|switch|sensor|relay|button
  final DeviceState state;
  final String room;
  final int? gpioPin;
  final String protocol; // gpio|zigbee|wifi|mqtt
  final bool online;
  final DateTime? lastSeen;

  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.state,
    required this.room,
    this.gpioPin,
    required this.protocol,
    required this.online,
    this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String? ?? 'switch',
        state: DeviceState.fromJson(
          (json['state'] as Map<String, dynamic>?) ?? {'on': false},
        ),
        room: json['room'] as String? ?? 'Unknown',
        gpioPin: json['gpio_pin'] as int?,
        protocol: json['protocol'] as String? ?? 'wifi',
        online: json['online'] as bool? ?? false,
        lastSeen: json['last_seen'] != null
            ? DateTime.tryParse(json['last_seen'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'state': state.toJson(),
        'room': room,
        'gpio_pin': gpioPin,
        'protocol': protocol,
        'online': online,
        'last_seen': lastSeen?.toIso8601String(),
      };

  Device copyWith({
    String? id,
    String? name,
    String? type,
    DeviceState? state,
    String? room,
    int? gpioPin,
    String? protocol,
    bool? online,
    DateTime? lastSeen,
  }) =>
      Device(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        state: state ?? this.state,
        room: room ?? this.room,
        gpioPin: gpioPin ?? this.gpioPin,
        protocol: protocol ?? this.protocol,
        online: online ?? this.online,
        lastSeen: lastSeen ?? this.lastSeen,
      );

  bool get isRelay => gpioPin != null;
  bool get isSensor => protocol == 'zigbee' || protocol == 'mqtt';
}

// ─── Demo data ────────────────────────────────────────────────────────────────
List<Device> demoDevices() => [
      Device(
        id: 'd1',
        name: 'Living Room Light',
        type: 'light',
        state: const DeviceState(on: true),
        room: 'Living Room',
        gpioPin: 17,
        protocol: 'gpio',
        online: true,
        lastSeen: DateTime.now(),
      ),
      Device(
        id: 'd2',
        name: 'Kitchen Switch',
        type: 'switch',
        state: const DeviceState(on: false),
        room: 'Kitchen',
        gpioPin: 27,
        protocol: 'gpio',
        online: true,
        lastSeen: DateTime.now(),
      ),
      Device(
        id: 'd3',
        name: 'Bedroom Fan',
        type: 'relay',
        state: const DeviceState(on: false),
        room: 'Bedroom',
        gpioPin: 22,
        protocol: 'gpio',
        online: true,
        lastSeen: DateTime.now(),
      ),
      Device(
        id: 'd4',
        name: 'Temperature Sensor',
        type: 'sensor',
        state: const DeviceState(on: true),
        room: 'Living Room',
        protocol: 'zigbee',
        online: true,
        lastSeen: DateTime.now(),
      ),
      Device(
        id: 'd5',
        name: 'Door Sensor',
        type: 'sensor',
        state: const DeviceState(on: false),
        room: 'Entrance',
        protocol: 'mqtt',
        online: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
