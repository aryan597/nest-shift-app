import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../hub/hub_provider.dart';
import '../hub/widgets/relay_card.dart';
import '../hub/widgets/sensor_card.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(width: 3, height: 40, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTypography.exo(fontSize: 13))),
        ]),
        backgroundColor: AppColors.raised,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(hubProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: devicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.warning, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load devices', style: AppTypography.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(hubProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (devices) {
          final relays = devices.where((d) => d.isRelay).toList();
          final sensors = devices.where((d) => d.isSensor).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(hubProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ─── RELAYS SECTION ─────────────────────────────────
                if (relays.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: 'RELAYS',
                        count: relays.length,
                        icon: Icons.developer_board_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RelayCard(
                            device: relays[i],
                            onToggle: (newVal) async {
                              HapticFeedback.mediumImpact();
                              try {
                                await ref.read(hubProvider.notifier).toggleRelay(
                                      relays[i].gpioPin!,
                                      newState: newVal,
                                    );
                              } catch (_) {
                                if (context.mounted) _showError(context, 'Failed to toggle ${relays[i].name}');
                              }
                            },
                          ),
                        ),
                        childCount: relays.length,
                      ),
                    ),
                  ),
                ],

                // ─── SENSORS SECTION ────────────────────────────────
                if (sensors.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(
                        title: 'SENSORS',
                        count: sensors.length,
                        icon: Icons.sensors_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SensorCard(device: sensors[i]),
                        ),
                        childCount: sensors.length,
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (relays.isEmpty && sensors.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.developer_board_outlined, size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text('No devices found', style: AppTypography.bodyMedium),
                          const SizedBox(height: 8),
                          Text('Connect GPIO devices to your hub', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.orbitron(fontSize: 12, color: color, letterSpacing: 2)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: AppTypography.mono(fontSize: 11, color: color)),
        ),
      ],
    );
  }
}
