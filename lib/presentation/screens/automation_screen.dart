import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/premium_container.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('Automations'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppTheme.primaryGold), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text('Active Routines', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _buildRoutineCard(context, 'Good Morning', 'Triggers at 7:00 AM\nOpens blinds, sets AC to 22°C', Icons.wb_sunny, true),
            const SizedBox(height: 16),
            _buildRoutineCard(context, 'Cinema Mode', 'Manual Trigger\nDims living room, powers on TV relay', Icons.tv, false),
            const SizedBox(height: 16),
            _buildRoutineCard(context, 'Security Night', 'Triggers at 11:30 PM\nLocks doors, enables camera alerts', Icons.shield_moon, true),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, String title, String desc, IconData icon, bool isActive) {
    return PremiumContainer(
      isActive: isActive,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: isActive ? AppTheme.primaryGold : Colors.white54, size: 28),
                  const SizedBox(width: 12),
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isActive ? Colors.white : Colors.white70
                  )),
                ],
              ),
              Switch(
                value: isActive,
                onChanged: (v) {},
                activeColor: AppTheme.primaryGold,
                inactiveTrackColor: AppTheme.backgroundBase,
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(desc, style: const TextStyle(color: Colors.white54, height: 1.5)),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Edit Routine', style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.edit, color: AppTheme.accentBlue, size: 16),
            ],
          )
        ],
      ),
    );
  }
}
