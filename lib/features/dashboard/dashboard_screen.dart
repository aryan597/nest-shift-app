import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/storage/secure_storage.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/connection_banner.dart';
import '../../shared/widgets/nest_panel.dart';
import '../../shared/widgets/floating_nav_bar.dart';
import '../dashboard/dashboard_provider.dart';
import '../dashboard/brain_status_provider.dart';
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

  static const _screens = [
    _HomeTab(),
    HubScreen(),
    AssistantScreen(),
    AutomationsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final connectionAsync = ref.watch(connectionProvider);
    final brainAsync = ref.watch(brainStatusProvider);
    final isConnected = connectionAsync.value?.isConnected ?? false;
    final brainOnline = brainAsync.value?.isOnline ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── TOP STATUS HEADER ───────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  // Logo
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(text: 'NEST', style: AppTypography.orbitron(fontSize: 20, color: AppColors.textPrimary, letterSpacing: 1.5)),
                      TextSpan(text: 'SHIFT', style: AppTypography.orbitron(fontSize: 20, color: AppColors.primary, letterSpacing: 1.5)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  FutureBuilder<bool>(
                    future: SecureStorageService.instance.isDemoMode(),
                    builder: (_, snap) => snap.data == true
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                            ),
                            child: Text('DEMO', style: AppTypography.mono(fontSize: 9, color: AppColors.accent)),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const Spacer(),
                  // Status chips
                  StatusChip(
                    variant: isConnected ? StatusChipVariant.online : StatusChipVariant.offline,
                    label: isConnected ? 'Online' : 'Offline',
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    variant: brainOnline ? StatusChipVariant.active : StatusChipVariant.idle,
                    label: brainOnline ? 'Brain: Active' : 'Brain: Offline',
                  ),
                ],
              ),
            ),

            // ─── CONNECTION BANNER ──────────────────────────────
            ConnectionBanner(isVisible: !isConnected),

            // ─── TAB BAR ────────────────────────────────────────
            FloatingNavBar(
              currentIndex: _tabIndex,
              onTap: (i) => setState(() => _tabIndex = i),
            ),

            // ─── LIVE STATS STRIP (Home tab only) ───────────────
            if (_tabIndex == 0) const _LiveStatsStrip(),

            // ─── SCREEN CONTENT ─────────────────────────────────
            Expanded(child: _screens[_tabIndex]),
            
            // ─── BOTTOM SAFE AREA ──────────────────────────────
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── HOME TAB (Quick overview) ─────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Good evening', style: AppTypography.exo(fontSize: 13, color: AppColors.textMuted)),
          Text('Home Overview', style: AppTypography.orbitron(fontSize: 22, letterSpacing: 1)),
          const SizedBox(height: 24),
          // Quick action cards
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.developer_board_rounded,
                  label: 'Hub',
                  sublabel: 'View devices',
                  color: AppColors.primary,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.psychology_rounded,
                  label: 'Assistant',
                  sublabel: 'AI control',
                  color: AppColors.accent,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.flash_on_rounded,
                  label: 'Automations',
                  sublabel: 'Manage rules',
                  color: AppColors.success,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Insights',
                  sublabel: 'AI suggestions',
                  color: const Color(0xFFFFB830),
                  onTap: () => GoRouter.of(context).push('/insights'),
                ),
              ),
            ],
          ),
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
    return NestPanel(
      glowColor: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(label, style: AppTypography.exo(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(sublabel, style: AppTypography.bodySmall),
            ],
          ),
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
