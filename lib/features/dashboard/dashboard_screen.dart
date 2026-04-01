import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';
import '../dashboard/dashboard_provider.dart';
import '../hub/hub_provider.dart';
import '../hub/hub_screen.dart';
import '../assistant/assistant_screen.dart';
import '../automations/automations_screen.dart';
import '../settings/settings_screen.dart';

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
    final isConnected = connectionAsync.value?.isConnected ?? false;

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
                  // Connection indicator (no text)
                  _ConnectionDot(isConnected: isConnected),
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

class _ConnectionDot extends StatelessWidget {
  final bool isConnected;
  const _ConnectionDot({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isConnected ? AppColors.success : AppColors.warning,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isConnected ? AppColors.success : AppColors.warning).withValues(alpha: 0.6),
            blurRadius: 6,
            spreadRadius: 2,
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
  @override
  Widget build(BuildContext context) {
    final hubInfo = ref.watch(hubSystemStatusProvider);
    final pinsAsync = ref.watch(gpioPinsProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // ─── Hub Card (simple, no stats) ────────────────────────────
          hubInfo.when(
            data: (h) => _HubCardSimple(hub: h),
            loading: () => _HubCardLoading(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 28),
          // ─── GPIO Pins Section ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GPIO PINS', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
              TextButton(
                onPressed: () => widget.onTabChange(1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Add', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          pinsAsync.when(
            data: (pins) {
              if (pins.isEmpty) {
                return _EmptyPinsCard(onConfigure: () => widget.onTabChange(1));
              }
              return Column(
                children: pins.map((pin) => _PinCard(
                  pin: pin,
                  onToggle: () async {
                    final newState = !(pin.state ?? false);
                    await ref.read(gpioPinsProvider.notifier).togglePin(pin.pin, newState);
                  },
                )).toList(),
              );
            },
            loading: () => Container(
              height: 120,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
            error: (e, _) => _ErrorCard(
              message: 'Failed to load pins',
              onRetry: () => ref.invalidate(gpioPinsProvider),
            ),
          ),
          const SizedBox(height: 28),
          // ─── Quick Actions ────────────────────────────────────────────
          Text('QUICK ACTIONS', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.settings_ethernet_rounded,
            title: 'Configure Pins',
            subtitle: 'Manage GPIO configuration',
            onTap: () => widget.onTabChange(1),
          ),
          _QuickActionTile(
            icon: Icons.psychology_rounded,
            title: 'AI Assistant',
            subtitle: 'Control with voice commands',
            onTap: () => widget.onTabChange(2),
          ),
          _QuickActionTile(
            icon: Icons.power_settings_new_rounded,
            title: 'Hub Management',
            subtitle: 'Reboot & restart services',
            onTap: () => widget.onTabChange(4),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _HubCardSimple extends ConsumerWidget {
  final HubSystemInfo hub;
  const _HubCardSimple({required this.hub});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;

    return Container(
      padding: EdgeInsets.all(style.cardRadius * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withValues(alpha: 0.12),
            theme.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(style.cardRadius * 1.5),
        border: Border.all(color: theme.primary.withValues(alpha: 0.2)),
        boxShadow: style.hasGlow ? [
          BoxShadow(color: theme.primary.withValues(alpha: style.glowIntensity * 0.15), blurRadius: 20, spreadRadius: 0),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: style.cardRadius * 4,
                height: style.cardRadius * 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: theme.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(style.cardRadius),
                  boxShadow: [
                    BoxShadow(color: theme.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 0),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(Icons.hub_rounded, color: Colors.white, size: style.iconSize + 6)),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: hub.mqttConnected ? theme.primary : AppColors.warning,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: (hub.mqttConnected ? theme.primary : AppColors.warning).withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: style.cardRadius),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hub.hubName, style: AppTypography.displaySmall.copyWith(color: theme.textPrimary, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('v${hub.version}', style: AppTypography.mono(fontSize: 10, color: theme.primary)),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.timer_outlined, size: 12, color: theme.textMuted),
                        SizedBox(width: 4),
                        Text(hub.uptimeFormatted, style: AppTypography.labelSmall.copyWith(fontSize: 10, color: theme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: style.cardRadius * 1.5),
          Row(
            children: [
              _MiniGauge(
                value: hub.cpuPercent,
                max: 100,
                label: 'CPU',
                icon: Icons.speed_rounded,
                color: theme.accent,
                theme: theme,
                style: style,
              ),
              SizedBox(width: style.cardRadius),
              _MiniGauge(
                value: hub.memoryMb.clamp(0, 100),
                max: 100,
                label: 'MEM',
                icon: Icons.memory_rounded,
                color: theme.primary,
                theme: theme,
                style: style,
                suffix: '${hub.memoryMb.toStringAsFixed(0)}MB',
              ),
              SizedBox(width: style.cardRadius),
              _MiniGauge(
                value: hub.diskPercent,
                max: 100,
                label: 'DISK',
                icon: Icons.storage_rounded,
                color: theme.accent,
                theme: theme,
                style: style,
                suffix: '${hub.diskPercent.toStringAsFixed(0)}%',
              ),
            ],
          ),
          SizedBox(height: style.cardRadius * 1.25),
          Container(
            padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.75),
            decoration: BoxDecoration(
              color: theme.surfaceRaised.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(style.cardRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.developer_board_rounded,
                  value: '${hub.deviceCount}',
                  label: 'Devices',
                  color: theme.primary,
                  theme: theme,
                  style: style,
                ),
                Container(width: 1, height: 20, color: theme.border),
                _StatItem(
                  icon: Icons.wifi_rounded,
                  value: '${hub.onlineDeviceCount}',
                  label: 'Online',
                  color: theme.primary,
                  theme: theme,
                  style: style,
                ),
                Container(width: 1, height: 20, color: theme.border),
                _StatItem(
                  icon: Icons.auto_awesome_rounded,
                  value: '${hub.activeAutomations}',
                  label: 'Flows',
                  color: theme.accent,
                  theme: theme,
                  style: style,
                ),
                Container(width: 1, height: 20, color: theme.border),
                _StatItem(
                  icon: Icons.schedule_rounded,
                  value: '${hub.activeSchedules}',
                  label: 'Sched',
                  color: theme.accent,
                  theme: theme,
                  style: style,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGauge extends StatelessWidget {
  final double value;
  final double max;
  final String label;
  final IconData icon;
  final Color color;
  final AppTheme theme;
  final ThemeStyle style;
  final String? suffix;

  const _MiniGauge({required this.value, required this.max, required this.label, required this.icon, required this.color, required this.theme, required this.style, this.suffix});

  @override
  Widget build(BuildContext context) {
    final percentage = (value / max).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(style.cardRadius * 0.75),
        decoration: BoxDecoration(
          color: theme.surfaceRaised.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(style.cardRadius),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: style.cardRadius * 2.5,
                  height: style.cardRadius * 2.5,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 3,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Icon(icon, size: style.iconSize * 0.7, color: color),
              ],
            ),
            SizedBox(height: 4),
            Text(suffix ?? '${percentage * 100 ~/ 1}%', style: AppTypography.mono(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 8, color: theme.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AppTheme theme;
  final ThemeStyle style;

  const _StatItem({required this.icon, required this.value, required this.label, required this.color, required this.theme, required this.style});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: style.iconSize * 0.65, color: color),
        SizedBox(height: 2),
        Text(value, style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w800, color: theme.textPrimary)),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 8, color: theme.textMuted)),
      ],
    );
  }
}

class _HubCard extends StatelessWidget {
  final HubSystemInfo hub;
  const _HubCard({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.hub_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hub.hubName, style: AppTypography.displaySmall),
                    Text('v${hub.version} • ${hub.uptimeFormatted}', style: AppTypography.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hub.mqttConnected 
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: hub.mqttConnected ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hub.mqttConnected ? 'Online' : 'Offline',
                      style: AppTypography.labelSmall.copyWith(
                        color: hub.mqttConnected ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HubStatChip(
                icon: Icons.memory_rounded,
                value: '${hub.memoryMb.toStringAsFixed(1)}MB',
                label: 'Memory',
                color: AppColors.accent,
              ),
              _HubStatChip(
                icon: Icons.speed_rounded,
                value: '${hub.cpuPercent.toStringAsFixed(1)}%',
                label: 'CPU',
                color: AppColors.primary,
              ),
              _HubStatChip(
                icon: Icons.storage_rounded,
                value: '${hub.diskPercent.toStringAsFixed(1)}%',
                label: 'Disk',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HubStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _HubStatChip({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 9)),
      ],
    );
  }
}

class _HubCardLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickStatCard({required this.icon, required this.value, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(value, style: AppTypography.mono(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinCard extends ConsumerWidget {
  final GpioPin pin;
  final VoidCallback onToggle;
  const _PinCard({required this.pin, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;
    final isOn = pin.state ?? false;
    final pinColor = pin.deviceType == 'relay' ? (isOn ? theme.accent : theme.textMuted) : theme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(style.cardRadius + 2),
      decoration: BoxDecoration(
        color: _getCardBackground(theme, style, isOn, pinColor),
        borderRadius: BorderRadius.circular(style.cardRadius),
        border: style.cardBorderWidth > 0 ? Border.all(
          color: isOn ? pinColor.withValues(alpha: 0.5) : theme.border,
          width: style.cardBorderWidth,
        ) : null,
        boxShadow: style.hasGlow && isOn ? [
          BoxShadow(
            color: pinColor.withValues(alpha: style.glowIntensity * 0.4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            width: style.iconSize + 16, height: style.iconSize + 16,
            padding: EdgeInsets.all(style.iconPadding - 8),
            decoration: BoxDecoration(
              color: pinColor.withValues(alpha: style.hasGlow ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(style.cardRadius - 4),
              boxShadow: style.hasGlow ? [
                BoxShadow(
                  color: pinColor.withValues(alpha: style.glowIntensity * 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ] : null,
            ),
            child: Icon(
              pin.deviceType == 'sensor' ? Icons.sensors_rounded : Icons.power_rounded,
              color: pinColor, size: style.iconSize,
            ),
          ),
          SizedBox(width: style.cardRadius),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pin.name ?? 'Pin ${pin.pin}', style: AppTypography.labelLarge.copyWith(color: theme.textPrimary, fontSize: 14)),
                Text('GPIO ${pin.pin} • ${pin.deviceType ?? 'relay'}', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
              ],
            ),
          ),
          if (pin.deviceType == 'relay')
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: style.cardRadius * 3.5, height: style.cardRadius * 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(style.cardRadius),
                  color: isOn ? theme.accent : theme.surfaceRaised,
                  border: Border.all(color: isOn ? theme.accent : theme.border),
                  boxShadow: style.hasGlow && isOn ? [
                    BoxShadow(
                      color: theme.accent.withValues(alpha: style.glowIntensity * 0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: style.cardRadius * 1.75 - 4, height: style.cardRadius * 2 - 4,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isOn ? Colors.white : theme.textMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOn ? Icons.power_rounded : Icons.power_off_rounded,
                      size: style.iconSize - 8, color: isOn ? theme.accent : Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: style.cardRadius * 0.7, vertical: style.cardRadius * 0.3),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(style.cardRadius * 0.5),
              ),
              child: Text('Sensor', style: AppTypography.labelSmall.copyWith(color: theme.primary)),
            ),
        ],
      ),
    );
  }

  Color _getCardBackground(AppTheme theme, ThemeStyle style, bool isOn, Color pinColor) {
    if (style.hasGradientOverlay && isOn) {
      return theme.surface.withValues(alpha: 0.9);
    }
    return style.cardStyle == CardStyle.flat 
        ? theme.surface 
        : theme.surface.withValues(alpha: style.cardStyle == CardStyle.glass ? 0.7 : 1.0);
  }
}

class _EmptyPinsCard extends ConsumerWidget {
  final VoidCallback onConfigure;
  const _EmptyPinsCard({required this.onConfigure});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;

    return GestureDetector(
      onTap: onConfigure,
      child: Container(
        padding: EdgeInsets.all(style.cardRadius + 10),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(style.cardRadius),
          border: style.cardBorderWidth > 0 ? Border.all(color: theme.border) : null,
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: theme.textMuted, size: style.iconSize + 16),
            SizedBox(height: style.cardRadius * 0.75),
            Text('No Pins Configured', style: AppTypography.labelLarge.copyWith(color: theme.textPrimary)),
            SizedBox(height: style.cardRadius * 0.25),
            Text('Tap to add GPIO pins', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: style.cardRadius * 0.7),
        padding: EdgeInsets.all(style.cardRadius),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(style.cardRadius),
          border: style.cardBorderWidth > 0 ? Border.all(color: theme.border) : null,
          boxShadow: style.hasGlow ? [
            BoxShadow(color: theme.primary.withValues(alpha: style.glowIntensity * 0.2), blurRadius: 8, spreadRadius: 0),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: style.cardRadius * 3, height: style.cardRadius * 3,
              padding: EdgeInsets.all(style.iconPadding - 4),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(style.cardRadius * 0.75),
              ),
              child: Icon(icon, color: theme.primary, size: style.iconSize - 2),
            ),
            SizedBox(width: style.cardRadius),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge.copyWith(color: theme.textPrimary)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.textMuted, size: style.iconSize),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatTile({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.mono(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;

    return Container(
      padding: EdgeInsets.all(style.cardRadius),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(style.cardRadius),
        border: style.cardBorderWidth > 0 ? Border.all(color: AppColors.error.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: style.iconSize),
          SizedBox(width: style.cardRadius * 0.75),
          Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: theme.textPrimary))),
          TextButton(onPressed: onRetry, child: Text('Retry', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
