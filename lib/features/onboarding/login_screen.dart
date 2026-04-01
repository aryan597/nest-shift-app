import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/auth/auth_provider.dart';
import '../pairing/pairing_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) {
        context.go('/pairing');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToPairing() {
    context.push('/pairing');
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
              decoration: const InputDecoration(
                labelText: 'IP Address',
                hintText: '192.168.1.100',
                prefixIcon: Icon(Icons.router_rounded),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portCtrl,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '8000',
                prefixIcon: Icon(Icons.cable_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Pairing Code',
                hintText: 'XXXX',
                prefixIcon: Icon(Icons.key_rounded),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  final success = await ref.read(pairingProvider.notifier).pairManually(
                        ip: ipCtrl.text.trim(),
                        port: int.tryParse(portCtrl.text.trim()) ?? 8000,
                        pairingCode: codeCtrl.text.trim(),
                      );
                  if (mounted) {
                    setState(() => _isLoading = false);
                    if (success) context.go('/dashboard');
                    else {
                      final s = ref.read(pairingProvider).value;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(s?.errorMessage ?? 'Connection failed'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
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

  Future<void> _continueAsDemo() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(pairingProvider.notifier).activateDemoMode();
      if (mounted) {
        context.go('/dashboard');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientPrimary,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.hub_rounded, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Text('Connect Your Hub', style: AppTypography.displayMedium),
              const SizedBox(height: 8),
              Text('Sign in or connect to start', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 24),
                    label: Text('Sign in with Google', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _goToPairing,
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
                    label: Text('Scan QR Code', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _showManualEntry,
                    icon: const Icon(Icons.keyboard_rounded, size: 22),
                    label: Text('Enter IP Manually', style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _continueAsDemo,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_outline_rounded, color: AppColors.accent, size: 22),
                        const SizedBox(width: 8),
                        Text('Demo Mode', style: AppTypography.labelLarge.copyWith(color: AppColors.accent)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Text('By continuing, you agree to our Terms of Service and Privacy Policy', 
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}