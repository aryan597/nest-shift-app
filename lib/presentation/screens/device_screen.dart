import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DeviceScreen extends StatelessWidget {
  final String deviceId;
  const DeviceScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(title: Text('Device $deviceId'), backgroundColor: AppTheme.backgroundBase),
      body: const Center(child: Text('Device Detail Screen', style: TextStyle(color: Colors.white70))),
    );
  }
}
