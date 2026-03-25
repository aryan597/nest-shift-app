import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/premium_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBase,
      appBar: AppBar(
        title: const Text('Account & Setup'),
        backgroundColor: AppTheme.backgroundBase,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.surfaceElevated,
                  child: Icon(Icons.person, size: 40, color: AppTheme.primaryGold),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Admin User', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 40),
              Text('System & Cloud', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              PremiumContainer(
                onTap: () {},
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.backgroundBase, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.cloud_sync, color: AppTheme.primaryGold),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cloud Sync Setup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Enable remote access via NestShift servers.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumContainer(
                onTap: () {},
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.backgroundBase, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.router, color: AppTheme.accentBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hub Network', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Manage local connection and pairing.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PremiumContainer(
                onTap: () {},
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text('Disconnect from Hub', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
