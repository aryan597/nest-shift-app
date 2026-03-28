import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Google Account Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Signed in with Google', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('demo@nestshift.local', style: AppTypography.displaySmall),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        const Text('Connected', style: TextStyle(color: AppColors.success, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Account Settings
            Text('ACCOUNT', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your name and photo',
              onTap: () => _showSnackBar(context, 'Profile editor coming soon'),
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage notification preferences',
              onTap: () => _showSnackBar(context, 'Notification settings coming soon'),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              subtitle: 'Manage your data and security',
              onTap: () => _showSnackBar(context, 'Privacy settings coming soon'),
            ),
            
            const SizedBox(height: 24),
            
            // Hub Settings
            Text('HUB', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.wifi_outlined,
              title: 'Connection',
              subtitle: '192.168.1.100:8000',
              onTap: () => _showConnectionDialog(context),
            ),
            _SettingsTile(
              icon: Icons.power_settings_new_outlined,
              title: 'Reboot Hub',
              subtitle: 'Restart your NestShift hub',
              onTap: () => _showRebootDialog(context),
            ),
            _SettingsTile(
              icon: Icons.qr_code_scanner,
              title: 'Re-pair Hub',
              subtitle: 'Connect to a different hub',
              onTap: () => context.go('/pairing'),
            ),
            
            const SizedBox(height: 24),
            
            // Demo Mode
            Text('DEVELOPMENT', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'Demo Mode',
              subtitle: 'Currently active',
              trailing: Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
              onTap: () => _showSnackBar(context, 'Demo mode is active'),
            ),
            
            const SizedBox(height: 24),
            
            // App Settings
            Text('APP', style: AppTypography.labelLarge.copyWith(color: AppColors.primary, letterSpacing: 2)),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Dark mode, themes',
              onTap: () => _showSnackBar(context, 'Appearance settings coming soon'),
            ),
            _SettingsTile(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: 'English',
              onTap: () => _showSnackBar(context, 'Language settings coming soon'),
            ),
            _SettingsTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs, contact support',
              onTap: () => _showSnackBar(context, 'Help & Support coming soon'),
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
                  backgroundColor: AppColors.warning,
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

  void _showConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hub Connection', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConnectionInfo(label: 'IP Address', value: '192.168.1.100'),
            _ConnectionInfo(label: 'Port', value: '8000'),
            _ConnectionInfo(label: 'Status', value: 'Connected'),
            _ConnectionInfo(label: 'Latency', value: '12ms'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRebootDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Reboot Hub?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This will restart your NestShift hub. Reconnection may take a minute.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hub reboot initiated'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Reboot'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('You will need to sign in again to access your hub.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SecureStorageService.instance.clearAll();
              if (context.mounted) {
                context.go('/onboarding/splash');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('NestShift', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Privacy-first smart home controller for your Raspberry Pi.', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 16),
            Text('Built with love for smart homes.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ConnectionInfo extends StatelessWidget {
  final String label;
  final String value;

  const _ConnectionInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTypography.bodySmall),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
