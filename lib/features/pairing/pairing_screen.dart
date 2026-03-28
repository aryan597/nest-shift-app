import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'pairing_provider.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  bool _hasScanned = false;
  final MobileScannerController _scannerCtrl = MobileScannerController();

  @override
  void dispose() {
    _scannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    setState(() => _hasScanned = true);
    HapticFeedback.mediumImpact();

    final success = await ref.read(pairingProvider.notifier).handleQrData(barcode!.rawValue!);
    if (!mounted) return;
    if (success) {
      context.go('/dashboard');
    } else {
      final state = ref.read(pairingProvider).value;
      _showError(state?.errorMessage ?? 'Invalid QR code');
      setState(() => _hasScanned = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(width: 3, height: 40, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(msg, style: AppTypography.bodySmall)),
        ]),
        backgroundColor: AppColors.raised,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showManualEntry() {
    final ipCtrl = TextEditingController();
    final portCtrl = TextEditingController(text: '8000');
    final codeCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manual Connection', style: AppTypography.displaySmall),
            const SizedBox(height: 6),
            Text('Enter your Pi\'s IP address and pairing code', style: AppTypography.bodySmall),
            const SizedBox(height: 20),
            TextField(
              controller: ipCtrl,
              decoration: const InputDecoration(labelText: 'IP Address', hintText: '192.168.1.100', prefixIcon: Icon(Icons.router_rounded)),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portCtrl,
              decoration: const InputDecoration(labelText: 'Port', hintText: '8000', prefixIcon: Icon(Icons.cable_rounded)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(labelText: 'Pairing Code', hintText: 'XXXX', prefixIcon: Icon(Icons.key_rounded)),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await ref.read(pairingProvider.notifier).pairManually(
                        ip: ipCtrl.text.trim(),
                        port: int.tryParse(portCtrl.text.trim()) ?? 8000,
                        pairingCode: codeCtrl.text.trim(),
                      );
                  if (mounted && success) context.go('/dashboard');
                  else if (mounted) {
                    final s = ref.read(pairingProvider).value;
                    _showError(s?.errorMessage ?? 'Connection failed');
                  }
                },
                child: const Text('Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateDemoMode() async {
    await ref.read(pairingProvider.notifier).activateDemoMode();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pairingProvider);
    final isConnecting = state.value?.status == PairingStatus.connecting;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Go back to login screen
        if (context.mounted) {
          context.go('/onboarding/login');
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen camera
          MobileScanner(
            controller: _scannerCtrl,
            onDetect: _handleBarcode,
          ),

          // Dark overlay vignette
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                ),
              ),
            ),
          ),

          // TOP header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(text: 'NEST', style: AppTypography.displayLarge.copyWith(color: Colors.white)),
                        TextSpan(text: 'SHIFT', style: AppTypography.displayLarge.copyWith(color: AppColors.primary)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Text('Point your camera at the QR code on your hub', style: AppTypography.bodySmall.copyWith(color: Colors.white60)),
                  ],
                ),
              ),
            ),
          ),

          // Scan frame overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner lines
                  ..._corners(),
                ],
              ),
            ),
          ),

          // Loading overlay when connecting
          if (isConnecting)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text('Connecting to hub...', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),

          // BOTTOM buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.keyboard_rounded, size: 18),
                      label: const Text('Enter IP Manually'),
                      onPressed: _showManualEntry,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _activateDemoMode,
                      child: Text(
                        'Demo Mode',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  List<Widget> _corners() {
    const size = 20.0;
    const width = 3.0;
    final color = AppColors.primary;
    return [
      Positioned(top: 0, left: 0, child: _Corner(size: size, width: width, color: color, top: true, left: true)),
      Positioned(top: 0, right: 0, child: _Corner(size: size, width: width, color: color, top: true, left: false)),
      Positioned(bottom: 0, left: 0, child: _Corner(size: size, width: width, color: color, top: false, left: true)),
      Positioned(bottom: 0, right: 0, child: _Corner(size: size, width: width, color: color, top: false, left: false)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double width;
  final Color color;
  final bool top;
  final bool left;
  const _Corner({required this.size, required this.width, required this.color, required this.top, required this.left});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: width) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: width) : BorderSide.none,
          left: left ? BorderSide(color: color, width: width) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: width) : BorderSide.none,
        ),
      ),
    );
  }
}
