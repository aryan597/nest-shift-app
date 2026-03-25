import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/graph_card.dart';
import '../widgets/energy_card.dart';
import '../providers/energy_provider.dart';
import '../providers/home_provider.dart';

class EnergyDashboard extends ConsumerWidget {
  const EnergyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyUsage = ref.watch(totalEnergyUsageProvider);
    final chartDataAsync = ref.watch(energyChartProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('Energy Intelligence'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EnergyCard(
                title: 'Total Home Load',
                currentUsageWatts: energyUsage,
                maxUsageWatts: 6000,
              ),
              const SizedBox(height: 24),
              chartDataAsync.when(
                data: (spots) => GraphCard(
                  title: 'Today\'s Consumption',
                  spots: spots,
                ),
                loading: () => const SizedBox(height: 250, child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SizedBox(height: 250, child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white)))),
              ),
              const SizedBox(height: 24),
              Text('Insights & Alerts', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.energyHigh.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppTheme.energyHigh, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('High Usage Detected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('AC Unit in Living Room has been running for 6 hours.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
