import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/skeuomorphic_container.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  void _pairWithPin() async {
    final pin = _pinController.text;
    if (pin.isEmpty) return;

    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);
    final success = await authRepo.pairWithPin(pin);
    setState(() => _isLoading = false);

    if (success && mounted) {
      context.go('/dashboard');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pairing failed. Try 0000 for Demo mode.')));
    }
  }

  void _showSampleQr() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceBase,
        title: const Text('Sample QR Data', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(
            data: '{"ip": "192.168.1.10", "port": 8000, "pairing_code": "0000"}',
            version: QrVersions.auto,
            backgroundColor: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryStatusOn)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('Pair to Hub'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            onPressed: _showSampleQr,
            tooltip: 'Generate Demo QR',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeuomorphicContainer(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MobileScanner(
                    onDetect: (capture) async {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty && !_isLoading) {
                        final rawVal = barcodes.first.rawValue;
                        if (rawVal != null && rawVal.contains('ip')) {
                           setState(() => _isLoading = true);
                           // Fake QR processing for demo
                           final authRepo = ref.read(authRepositoryProvider);
                           final success = await authRepo.pairWithPin('0000'); // Faking with pin
                           if (success && mounted) {
                             context.go('/dashboard');
                           }
                        }
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Searching for NestShift OS...',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.primaryStatusOn),
              ),
              const SizedBox(height: 48),
              Text(
                'Or connect manually',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SkeuomorphicContainer(
                child: TextField(
                  controller: _pinController,
                  style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0000',
                    hintStyle: TextStyle(color: Colors.white38),
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isLoading ? null : _pairWithPin,
                child: SkeuomorphicContainer(
                  height: 60,
                  isPressed: _isLoading,
                  child: Center(
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: AppTheme.primaryStatusOn)
                        : Text('CONNECT', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryStatusOn)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
