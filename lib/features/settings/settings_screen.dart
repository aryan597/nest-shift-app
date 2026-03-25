import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/widgets/nest_panel.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load', style: AppTypography.bodySmall)),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── CONNECTION ───────────────────────────────────────────
            _SectionLabel('CONNECTION'),
            const SizedBox(height: 10),
            NestPanel(
              child: Column(
                children: [
                  _InfoTile(
                    label: 'Pi IP Address',
                    value: settings.ip ?? '—',
                    icon: Icons.router_rounded,
                    onTap: settings.ip != null
                        ? () {
                            Clipboard.setData(ClipboardData(text: settings.ip!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('IP copied', style: AppTypography.exo(fontSize: 13)), backgroundColor: AppColors.raised),
                            );
                          }
                        : null,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _InfoTile(
                    label: 'Port',
                    value: settings.port.toString(),
                    icon: Icons.cable_rounded,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _InfoTile(
                    label: 'Hub ID',
                    value: settings.hubId ?? '—',
                    icon: Icons.fingerprint_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.wifi_tethering_rounded, size: 16),
                    label: const Text('Test Connection'),
                    onPressed: () async {
                      try {
                        final isDemoMode = await SecureStorageService.instance.isDemoMode();
                        if (isDemoMode) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: _successRow('Demo mode — no real connection'), backgroundColor: AppColors.raised),
                          );
                          return;
                        }
                        final dio = await DioClient.instance.dio;
                        await dio.get(ApiEndpoints.brainStatus);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: _successRow('Hub reachable ✓'), backgroundColor: AppColors.raised),
                        );
                      } catch (_) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: _errorRow('Hub unreachable'), backgroundColor: AppColors.raised),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                    label: const Text('Re-pair'),
                    onPressed: () => context.go('/pairing'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── BRAIN ────────────────────────────────────────────────
            _SectionLabel('BRAIN'),
            const SizedBox(height: 10),
            NestPanel(
              child: Column(
                children: [
                  _InfoTile(label: 'Status', value: settings.isDemoMode ? 'Demo Mode' : 'Connected', icon: Icons.psychology_rounded),
                  const Divider(height: 1, color: AppColors.border),
                  _InfoTile(label: 'Mode', value: settings.isDemoMode ? 'Demo' : 'Live', icon: Icons.memory_rounded),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export Training Data'),
              onPressed: () async {
                try {
                  final isDemoMode = await SecureStorageService.instance.isDemoMode();
                  if (isDemoMode) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: _errorRow('Not available in demo mode'), backgroundColor: AppColors.raised),
                    );
                    return;
                  }
                  final dio = await DioClient.instance.dio;
                  await dio.get(ApiEndpoints.brainExportTraining);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: _successRow('Export complete'), backgroundColor: AppColors.raised),
                  );
                } catch (_) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: _errorRow('Export failed'), backgroundColor: AppColors.raised),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // ── APP ──────────────────────────────────────────────────
            _SectionLabel('APP'),
            const SizedBox(height: 10),
            NestPanel(
              child: Column(
                children: [
                  _InfoTile(label: 'Version', value: '1.0.0', icon: Icons.info_outline_rounded),
                  const Divider(height: 1, color: AppColors.border),
                  _NavTile(label: 'Privacy Policy', icon: Icons.privacy_tip_outlined, onTap: () => _showTextScreen(context, 'Privacy Policy', _privacyText)),
                  const Divider(height: 1, color: AppColors.border),
                  _NavTile(label: 'Terms of Use', icon: Icons.gavel_rounded, onTap: () => _showTextScreen(context, 'Terms of Use', _termsText)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── DANGER ZONE ──────────────────────────────────────────
            _SectionLabel('DANGER ZONE', color: AppColors.warning),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                color: AppColors.warning.withValues(alpha: 0.04),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text('This action cannot be undone', style: AppTypography.exo(fontSize: 12, color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.link_off_rounded, size: 18),
                      label: const Text('Unpair Hub'),
                      onPressed: () => _confirmUnpair(context, ref),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _successRow(String msg) => Row(children: [Container(width: 3, height: 36, color: AppColors.success), const SizedBox(width: 12), Text(msg, style: AppTypography.exo(fontSize: 13))]);
  Widget _errorRow(String msg) => Row(children: [Container(width: 3, height: 36, color: AppColors.warning), const SizedBox(width: 12), Text(msg, style: AppTypography.exo(fontSize: 13))]);

  void _confirmUnpair(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unpair Hub?', style: AppTypography.orbitron(fontSize: 16, color: AppColors.warning)),
        content: Text('This will clear all credentials and return you to the pairing screen.', style: AppTypography.bodySmall),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(settingsProvider.notifier).unpair();
              if (context.mounted) context.go('/pairing');
            },
            child: Text('Unpair', style: AppTypography.exo(color: AppColors.warning, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showTextScreen(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: Text(title, style: AppTypography.orbitron(fontSize: 16))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Text(content, style: AppTypography.bodySmall.copyWith(height: 1.7)),
          ),
        ),
      ),
    );
  }

  static const _privacyText = '''NestShift Privacy Policy

Last updated: March 2026

NestShift is designed with privacy at its core. This app operates entirely on your local network and communicates only with your Raspberry Pi hub.

DATA WE DO NOT COLLECT
• No analytics or crash reporting
• No external API calls
• No cloud storage of device data

DATA STORED ON DEVICE
• Authentication token (encrypted, flutter_secure_storage)
• Hub IP address and port
• App preferences

LOCAL NETWORK
All communication happens between your phone and your local Pi hub. No data leaves your network.''';

  static const _termsText = '''NestShift Terms of Use

Last updated: March 2026

By using the NestShift app, you agree to these terms.

USE RESTRICTIONS
This app is designed for personal, non-commercial use with NestShift OS running on a Raspberry Pi on your local network.

NO WARRANTY
The software is provided as-is. NestShift Ltd is not liable for any damage to devices or property resulting from use.

OPEN SOURCE
Core components of this project may be open source. Check our documentation for details.''';
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const _SectionLabel(this.text, {this.color});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.orbitron(
          fontSize: 10,
          color: color ?? AppColors.textMuted,
          letterSpacing: 2,
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  const _InfoTile({required this.label, required this.value, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.exo(fontSize: 13, color: AppColors.textSecondary)),
            const Spacer(),
            Text(value, style: AppTypography.mono(fontSize: 13, color: AppColors.textPrimary)),
            if (onTap != null) ...[const SizedBox(width: 8), const Icon(Icons.copy_rounded, size: 14, color: AppColors.textMuted)],
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _NavTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.exo(fontSize: 13, color: AppColors.textSecondary)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
