import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/hub/hub_provider.dart';
import '../../features/dashboard/dashboard_provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hubInfo = ref.watch(hubSystemStatusProvider);
    final themeState = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: themeState.theme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeState.theme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeState.theme.id == 'monochrome' 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : themeState.theme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: themeState.theme.gradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: authState.user?.avatarUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(authState.user!.avatarUrl!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? (settings.value?.isDemoMode == true ? 'Demo User' : 'Not signed in'),
                          style: AppTypography.displaySmall,
                        ),
                        if (authState.user?.email != null)
                          Text(authState.user!.email!, style: AppTypography.bodySmall.copyWith(
                            color: themeState.theme.textSecondary,
                          )),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (settings.value?.isDemoMode == true ? AppColors.warning : AppColors.success)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: settings.value?.isDemoMode == true ? AppColors.warning : AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                settings.value?.isDemoMode == true ? 'Demo Mode' : 'Signed in',
                                style: AppTypography.labelSmall.copyWith(
                                  color: settings.value?.isDemoMode == true ? AppColors.warning : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: themeState.theme.textSecondary),
                    onPressed: () => _showEditProfileDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Hub Connection Section
            Text('HUB CONNECTION', style: AppTypography.labelLarge.copyWith(
              color: themeState.theme.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            hubInfo.when(
              data: (hub) => _HubConnectionCard(
                hubName: hub.hubName,
                hubId: hub.hubId,
                version: hub.version,
                ip: settings.value?.ip ?? 'Unknown',
                port: settings.value?.port?.toString() ?? '8000',
                uptime: hub.uptimeFormatted,
                status: hub.mqttConnected,
                onTap: () => _showConnectionDetails(context, hub, settings.value),
              ),
              loading: () => _HubConnectionCardLoading(),
              error: (_, __) => _HubConnectionCard(
                hubName: 'Hub',
                hubId: 'Unknown',
                version: '1.0.0',
                ip: settings.value?.ip ?? 'Unknown',
                port: settings.value?.port?.toString() ?? '8000',
                uptime: '—',
                status: false,
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),

            // Hub Management
            Text('HUB MANAGEMENT', style: AppTypography.labelLarge.copyWith(
              color: themeState.theme.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.power_settings_new_outlined,
              title: 'Reboot Hub',
              subtitle: 'Restart all services',
              onTap: () => _showRebootDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.qr_code_scanner,
              title: 'Re-pair Hub',
              subtitle: 'Connect to a different hub',
              onTap: () => context.go('/pairing'),
            ),
            
            const SizedBox(height: 24),
            
            // Privacy Section
            Text('PRIVACY', style: AppTypography.labelLarge.copyWith(
              color: themeState.theme.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear History',
              subtitle: 'Delete command history and logs',
              onTap: () => _showClearHistoryDialog(context),
            ),
            _SettingsTile(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your data',
              onTap: () => _showSnackBar(context, 'Data export coming soon'),
            ),
            _SettingsTile(
              icon: Icons.visibility_off_outlined,
              title: 'Privacy Settings',
              subtitle: 'Manage data sharing preferences',
              onTap: () => _showPrivacySettings(context),
            ),
            
            const SizedBox(height: 24),
            
            // Appearance
            Text('APPEARANCE', style: AppTypography.labelLarge.copyWith(
              color: themeState.theme.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: themeState.theme.name,
              onTap: () => _showThemeSelector(context, ref),
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () => _showSnackBar(context, 'Only English available'),
            ),
            
            const SizedBox(height: 24),
            
            // Help & Support
            Text('SUPPORT', style: AppTypography.labelLarge.copyWith(
              color: themeState.theme.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'FAQs and guides',
              onTap: () => _showHelpCenter(context),
            ),
            _SettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'Report a Bug',
              subtitle: 'Help us improve the app',
              onTap: () => _showBugReport(context),
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Contact Support',
              subtitle: 'Get help from our team',
              onTap: () => _showContactSupport(context),
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            
            const SizedBox(height: 24),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSignOutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeState.theme.brightness == Brightness.dark 
                      ? AppColors.warning 
                      : Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final nameController = TextEditingController(text: authState.user?.name ?? '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).updateProfile(name: nameController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConnectionDetails(BuildContext context, HubSystemInfo hub, SettingsState? settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hub Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ConnectionRow(label: 'Hub Name', value: hub.hubName),
            _ConnectionRow(label: 'Hub ID', value: hub.hubId),
            _ConnectionRow(label: 'Version', value: hub.version),
            _ConnectionRow(label: 'IP', value: settings?.ip ?? 'Unknown'),
            _ConnectionRow(label: 'Port', value: settings?.port?.toString() ?? '8000'),
            _ConnectionRow(label: 'Uptime', value: hub.uptimeFormatted),
            _ConnectionRow(label: 'Status', value: hub.mqttConnected ? 'Online' : 'Offline'),
            _ConnectionRow(label: 'Devices', value: '${hub.onlineDeviceCount}/${hub.deviceCount}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showRebootDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reboot Hub?'),
        content: const Text('This will restart all services. Reconnection may take a minute.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(hubProvider.notifier).rebootHub();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hub reboot initiated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Reboot'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear History?'),
        content: const Text('This will delete all command history and logs. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(title: const Text('Share analytics'), value: true, onChanged: (v) {}),
            SwitchListTile(title: const Text('Crash reports'), value: true, onChanged: (v) {}),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Theme', style: AppTypography.displaySmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppThemes.all.length,
                itemBuilder: (ctx, i) {
                  final theme = AppThemes.all[i];
                  return GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).setTheme(theme.id);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.primary.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(theme.name, style: TextStyle(
                            color: theme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help Center', style: AppTypography.displaySmall),
            const SizedBox(height: 20),
            _FAQTile(question: 'How do I connect to a hub?', answer: 'Go to Pairing screen and scan the QR code or enter hub IP manually.'),
            _FAQTile(question: 'How do I add GPIO pins?', answer: 'Navigate to Devices tab and tap "Add Pin" to configure.'),
            _FAQTile(question: 'How do automations work?', answer: 'Create triggers and actions in the Automations tab.'),
          ],
        ),
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Report Bug'),
        content: const Text('Please describe the bug you encountered. We appreciate your feedback!'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bug report submitted. Thank you!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Contact Support'),
        content: const Text('Email: support@nestshift.com\n\nWe typically respond within 24 hours.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out?'),
        content: const Text('You will need to sign in again to access your hub.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () async {
              Navigator.pop(ctx);
              await SecureStorageService.instance.clearAll();
              if (context.mounted) {
                context.go('/');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientPrimary),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('NestShift'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 8),
            Text('Smart GPIO Hub Control'),
            SizedBox(height: 16),
            Text('© 2024 NestShift Ltd'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _HubConnectionCard extends StatelessWidget {
  final String hubName;
  final String hubId;
  final String version;
  final String ip;
  final String port;
  final String uptime;
  final bool status;
  final VoidCallback onTap;

  const _HubConnectionCard({
    required this.hubName, required this.hubId, required this.version,
    required this.ip, required this.port, required this.uptime,
    required this.status, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: status ? AppColors.success.withValues(alpha: 0.3) : AppColors.warning.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: status ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                status ? Icons.wifi : Icons.wifi_off,
                color: status ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hubName, style: AppTypography.labelLarge),
                  Text('$ip:$port', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  Text('Uptime: $uptime', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status ? AppColors.success.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status ? 'Online' : 'Offline',
                style: AppTypography.labelSmall.copyWith(
                  color: status ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _HubConnectionCardLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon, required this.title, required this.subtitle,
    this.trailing, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConnectionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: AppTypography.mono(fontSize: 12)),
        ],
      ),
    );
  }
}

class _FAQTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.question, style: AppTypography.labelLarge)),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textMuted),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              Text(widget.answer, style: AppTypography.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}