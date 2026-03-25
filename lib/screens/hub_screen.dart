import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/nestshift_colors.dart';
import '../components/nest_panel.dart';

// Simple Providers for UI state
class WattsNotifier extends Notifier<double> {
  @override
  double build() => 847.0;
}
final wattsProvider = NotifierProvider<WattsNotifier, double>(WattsNotifier.new);

class IsListeningNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  
  void setListening(bool val) {
    state = val;
  }
}
final isListeningProvider = NotifierProvider<IsListeningNotifier, bool>(IsListeningNotifier.new);

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watts = ref.watch(wattsProvider);
    final isListening = ref.watch(isListeningProvider);

    return Scaffold(
      backgroundColor: NestShiftColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTapDown: (_) => ref.read(isListeningProvider.notifier).setListening(true),
        onTapUp: (_) => ref.read(isListeningProvider.notifier).setListening(false),
        onTapCancel: () => ref.read(isListeningProvider.notifier).setListening(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isListening ? 200 : 80,
          height: 80,
          decoration: BoxDecoration(
            color: isListening ? NestShiftColors.primary : NestShiftColors.surfaceElevated,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isListening ? NestShiftColors.primaryGlow : const Color(0xFF2D3748),
              width: 2,
            ),
            boxShadow: [
              if (isListening)
                BoxShadow(
                  color: NestShiftColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: isListening
              ? const CircularProgressIndicator(color: Colors.white) // Placeholder for Waveform
              : const Icon(Icons.mic, color: NestShiftColors.primary, size: 36),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADLINE: Brutalist Energy Usage
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      NestShiftColors.surfaceElevated.withOpacity(0.5),
                      NestShiftColors.background,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(top: 48, bottom: 32, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LIVE CONSUMPTION',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${watts.toInt()} W',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: NestShiftColors.success,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Grid Sync Active · £0.24 / hr',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. HARDWARE STATUS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CORE SYSTEM STATUS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    NestPanel(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildHardwareRow('HUB COMPUTE', 'Raspberry Pi 5 (4GB)'),
                          _buildHardwareRow('LOCAL AI', 'Whisper + Node-RED'),
                          _buildHardwareRow('CPU TEMP', '42.5°C', isWarning: true),
                          _buildHardwareRow('PROTOCOLS', 'Zigbee: Online | Matter: Standby'),
                          _buildHardwareRow('DEVICES CONNECTED', '14 Active Nodes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. INTEGRATIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXTERNAL INTEGRATIONS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildIntegrationToggle('DOORBELL', 'Camera')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildIntegrationToggle('ALEXA', 'Bridge')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildIntegrationToggle('ALARM', 'Disarmed', isAlert: true)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 4. SPATIAL ZONES (Rooms)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPATIAL ZONES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildRoomCard('LIVING', '3 Active')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRoomCard('KITCHEN', '0 Active')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildRoomCard('BEDROOM', '1 Active')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildRoomCard('OUTDOOR', 'Offline')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 140), // Spacing for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHardwareRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: NestShiftColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              color: isWarning ? NestShiftColors.warning : NestShiftColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationToggle(String title, String subtitle, {bool isAlert = false}) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NestShiftColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAlert ? NestShiftColors.warning : const Color(0xFF2D3748)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: NestShiftColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w900),
          ),
          Text(
            subtitle,
            style: TextStyle(color: isAlert ? NestShiftColors.warning : NestShiftColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(String title, String status) {
    final isActive = status.contains('Active');
    return NestPanel(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: NestShiftColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900),
          ),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? NestShiftColors.success : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(color: NestShiftColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
