import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/connection_banner.dart';
import '../../shared/widgets/nest_panel.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../shared/widgets/floating_nav_bar.dart';
import '../dashboard/dashboard_provider.dart';
import '../dashboard/brain_status_provider.dart';
import '../hub/hub_screen.dart';
import '../assistant/assistant_screen.dart';
import '../automations/automations_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _tabIndex = 0;

  Future<bool> _onWillPop() async {
    // If not on home tab, go to home tab
    if (_tabIndex != 0) {
      setState(() => _tabIndex = 0);
      return false;
    }
    // On home tab, show exit confirmation
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Exit App?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to exit?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    
    if (shouldPop == true) {
      // Exit the app
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionProvider);
    final brainAsync = ref.watch(brainStatusProvider);
    final isConnected = connectionAsync.value?.isConnected ?? false;
    final brainOnline = brainAsync.value?.isOnline ?? false;

    // Screens moved to local list to support instance-specific logic or refreshes
    final screens = [
      _HomeTab(onTabChange: (i) => setState(() => _tabIndex = i)),
      const HubScreen(),
      const AssistantScreen(),
      const AutomationsScreen(),
      const SettingsScreen(),
    ];

    final titles = ['Welcome Home', 'Devices', 'Assistant', 'Automations', 'Settings'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ─── MINIMAL HEADER ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NESTSHIFT', style: AppTypography.displaySmall.copyWith(letterSpacing: 2, color: AppColors.primary, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(
                        titles[_tabIndex],
                        style: AppTypography.displayMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Notification Bell
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Stack(
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.textMuted,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Online Status
                  _ConnectionIndicator(isConnected: isConnected),
                ],
              ),
            ),

          // ─── SCREEN CONTENT ─────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[_tabIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ModernNavBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
      ),
    ),
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final bool isConnected;
  const _ConnectionIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isConnected ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.success : AppColors.warning,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: (isConnected ? AppColors.success : AppColors.warning).withValues(alpha: 0.5), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Online' : 'Offline',
            style: AppTypography.labelSmall.copyWith(
              color: isConnected ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.grid_view_rounded, active: currentIndex == 0, onTap: () => onTap(0), label: 'Home'),
          _NavBarItem(icon: Icons.developer_board_rounded, active: currentIndex == 1, onTap: () => onTap(1), label: 'Devices'),
          _NavBarItem(icon: Icons.psychology_rounded, active: currentIndex == 2, onTap: () => onTap(2), label: 'AI'),
          _NavBarItem(icon: Icons.auto_awesome_rounded, active: currentIndex == 3, onTap: () => onTap(3), label: 'Flows'),
          _NavBarItem(icon: Icons.settings_rounded, active: currentIndex == 4, onTap: () => onTap(4), label: 'Settings'),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String label;

  const _NavBarItem({required this.icon, required this.active, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: active ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HOME TAB (Quick overview) ─────────────────────────────────────────────────

class _HomeTab extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  const _HomeTab({required this.onTabChange});

  @override
  ConsumerState<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<_HomeTab> {
  bool _aiModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // AI Mode Toggle Card
          GestureDetector(
            onTap: () {
              setState(() => _aiModeEnabled = !_aiModeEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_aiModeEnabled ? 'AI Mode enabled - AI will control your home' : 'AI Mode disabled'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: _aiModeEnabled
                    ? LinearGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.3), AppColors.accent.withValues(alpha: 0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: _aiModeEnabled ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _aiModeEnabled ? AppColors.primary : AppColors.border,
                  width: _aiModeEnabled ? 2 : 1,
                ),
                boxShadow: _aiModeEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _aiModeEnabled ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: _aiModeEnabled ? Colors.white : AppColors.textMuted,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Control',
                          style: AppTypography.displaySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _aiModeEnabled ? 'AI is managing your home' : 'Enable AI to automate your home',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: _aiModeEnabled ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.3),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: _aiModeEnabled ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _aiModeEnabled ? Icons.check : Icons.close,
                          size: 16,
                          color: _aiModeEnabled ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick Stats Row
          Row(
            children: [
              Expanded(child: _StatCard(icon: Icons.developer_board_rounded, label: 'Devices', value: '4', color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.sensors, label: 'Sensors', value: '2', color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.auto_awesome, label: 'Flows', value: '2', color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 32),
          Text('Quick Controls', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          // Grid layout
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _QuickActionCard(
                icon: Icons.developer_board_rounded,
                label: 'Devices',
                sublabel: '4 online',
                color: AppColors.primary,
                onTap: () => widget.onTabChange(1),
              ),
              _QuickActionCard(
                icon: Icons.psychology_rounded,
                label: 'Assistant',
                sublabel: 'Voice ready',
                color: AppColors.accent,
                onTap: () => widget.onTabChange(2),
              ),
              _QuickActionCard(
                icon: Icons.auto_awesome_rounded,
                label: 'Flows',
                sublabel: '2 active',
                color: AppColors.success,
                onTap: () => widget.onTabChange(3),
              ),
              _QuickActionCard(
                icon: Icons.insights_rounded,
                label: 'Insights',
                sublabel: 'View reports',
                color: const Color(0xFFFFB830),
                onTap: () => GoRouter.of(context).push('/insights'),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.displaySmall.copyWith(color: color)),
          Text(label, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.sublabel, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(label, style: AppTypography.labelLarge.copyWith(fontSize: 14)),
            const SizedBox(height: 2),
            Text(sublabel, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ─── LIVE STATS STRIP ─────────────────────────────────────────────────────────

class _LiveStatsStrip extends ConsumerWidget {
  const _LiveStatsStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(
      // Simple count from hub provider if loaded, else fallback
      // Using a simple provider watch here
      brainStatusProvider,
    );
    final uptime = devicesAsync.value?.uptime ?? '—';

    return Container(
      height: 52,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _StatTile(value: '3', label: 'Active', color: AppColors.primary),
          _StatTile(value: '2', label: 'Relays', color: AppColors.success),
          _StatTile(value: '1', label: 'Rules', color: AppColors.accent),
          _StatTile(value: uptime, label: 'Uptime', color: AppColors.primary),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.border)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTypography.mono(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: AppTypography.exo(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
