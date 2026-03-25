import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/room_card.dart';
import '../widgets/energy_card.dart';
import '../widgets/premium_container.dart';
import '../providers/home_provider.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final energyUsage = ref.watch(totalEnergyUsageProvider);

    return Scaffold(
        backgroundColor: AppTheme.backgroundBase,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppTheme.backgroundBase,
                floating: true,
                title: Text('NestShift Hub', style: Theme.of(context).textTheme.headlineMedium),
                actions: [
                  GestureDetector(
                    onTap: () => context.push('/ai'),
                    child: PremiumContainer(
                      height: 48,
                      width: 48,
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Icon(Icons.psychology, color: AppTheme.primaryGold, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHomeStatus(context),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => context.push('/energy'),
                      child: EnergyCard(
                        title: 'Current Load',
                        currentUsageWatts: energyUsage,
                        maxUsageWatts: 6000,
                      )
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rooms', style: Theme.of(context).textTheme.titleMedium),
                        const Icon(Icons.add, color: AppTheme.primaryGold),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              
              roomsAsync.when(
                data: (rooms) => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final room = rooms[index];
                        return RoomCard(
                          title: room.name,
                          deviceCount: room.deviceCount,
                          activeCount: room.deviceCount > 0 ? 1 : 0,
                          temperature: room.temperature,
                          onTap: () => context.push('/room/${room.id}'),
                        );
                      },
                      childCount: rooms.length,
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverToBoxAdapter(child: Text('Error: $e')),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      );
  }

  Widget _buildHomeStatus(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PremiumContainer(
            height: 80,
            isActive: true, // Armed state is glowing gold
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, color: AppTheme.primaryGold),
                SizedBox(width: 8),
                Text('Armed', style: TextStyle(color: AppTheme.primaryGold, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PremiumContainer(
            height: 80,
            isActive: false,
            padding: const EdgeInsets.all(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bedtime, color: Colors.white54),
                SizedBox(width: 8),
                Text('Sleep 2h', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
