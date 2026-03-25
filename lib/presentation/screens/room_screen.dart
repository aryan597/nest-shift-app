import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/device_card.dart';
import '../providers/room_provider.dart';

class RoomScreen extends ConsumerWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'light': return Icons.lightbulb;
      case 'climate': return Icons.ac_unit;
      case 'relay': return Icons.power;
      default: return Icons.device_hub;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(roomDevicesProvider(roomId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('Room View'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: devicesAsync.when(
          data: (devices) => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(
                title: device.name,
                subtitle: device.isOn ? 'ON' : 'OFF',
                icon: _getIconForType(device.type),
                isOn: device.isOn,
                onToggle: (val) {
                  ref.read(devicesProvider.notifier).toggleDevice(device.id, val);
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        ),
      ),
    );
  }
}
