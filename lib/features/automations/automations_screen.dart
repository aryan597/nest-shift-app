import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/models/automation.dart';
import '../../shared/widgets/nest_panel.dart';
import '../../shared/widgets/glass_panel.dart';
import '../../features/hub/widgets/metallic_toggle.dart';
import 'automations_provider.dart';

class AutomationsScreen extends ConsumerWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final automationsAsync = ref.watch(automationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: () => _showNewAutomationSheet(context, ref),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: automationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.warning, size: 40),
              const SizedBox(height: 16),
              Text('Sync failed', style: AppTypography.displaySmall),
              TextButton(onPressed: () => ref.refresh(automationsProvider), child: const Text('Retry')),
            ],
          ),
        ),
        data: (automations) {
          if (automations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 24),
                  Text('No Flows Yet', style: AppTypography.displayMedium),
                  const SizedBox(height: 8),
                  Text('Automate your home with smart logic.', style: AppTypography.bodySmall),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(automationsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: automations.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AutomationCard(
                  automation: automations[i],
                  onToggle: () => ref.read(automationsProvider.notifier).toggle(automations[i].id),
                  onTap: () => _showDetailSheet(context, ref, automations[i]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, Automation automation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(automation.name, style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            Text('Trigger: ${automation.triggerDescription}', style: AppTypography.bodySmall),
            const SizedBox(height: 6),
            Text('Action: ${automation.action.type}', style: AppTypography.bodySmall),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Delete'),
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(automationsProvider.notifier).delete(automation.id);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewAutomationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _NewAutomationSheet(onSubmit: (name, trigger, action) async {
        await ref.read(automationsProvider.notifier).create(
              name: name,
              trigger: trigger,
              action: action,
            );
        if (context.mounted) Navigator.pop(context);
      }),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  final Automation automation;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _AutomationCard({required this.automation, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTimeBased = automation.trigger.type == 'time';
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: automation.enabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.raised.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isTimeBased ? Icons.schedule_rounded : Icons.bolt_rounded,
                  size: 24,
                  color: automation.enabled ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(automation.name, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(automation.triggerDescription, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MetallicToggle(
                value: automation.enabled,
                small: true,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── NEW AUTOMATION SHEET (3-step) ────────────────────────────────────────────

class _NewAutomationSheet extends StatefulWidget {
  final Future<void> Function(String name, AutomationTrigger trigger, AutomationAction action) onSubmit;

  const _NewAutomationSheet({required this.onSubmit});

  @override
  State<_NewAutomationSheet> createState() => _NewAutomationSheetState();
}

class _NewAutomationSheetState extends State<_NewAutomationSheet> {
  int _step = 0;
  String _triggerType = 'time';
  String _actionType = 'device_command';
  final _nameCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: '08:00');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Steps indicator
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= _step ? AppColors.primary : AppColors.raised,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          const SizedBox(height: 20),

          if (_step == 0) ...[
            Text('Step 1: Choose Trigger', style: AppTypography.displaySmall),
            const SizedBox(height: 16),
            _OptionTile(title: 'Time-based', subtitle: 'Runs at a specific time', icon: Icons.schedule_rounded, selected: _triggerType == 'time', onTap: () => setState(() => _triggerType = 'time')),
            const SizedBox(height: 8),
            _OptionTile(title: 'Device State', subtitle: 'Triggers when a device changes', icon: Icons.developer_board_rounded, selected: _triggerType == 'device_state', onTap: () => setState(() => _triggerType = 'device_state')),
            const SizedBox(height: 8),
            _OptionTile(title: 'Scene', subtitle: 'Activates on a scene trigger', icon: Icons.auto_awesome_rounded, selected: _triggerType == 'scene', onTap: () => setState(() => _triggerType = 'scene')),
            if (_triggerType == 'time') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _timeCtrl,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)', prefixIcon: Icon(Icons.access_time_rounded)),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ],

          if (_step == 1) ...[
            Text('Step 2: Choose Action', style: AppTypography.displaySmall),
            const SizedBox(height: 16),
            _OptionTile(title: 'Device Command', subtitle: 'Turn a device on or off', icon: Icons.power_settings_new_rounded, selected: _actionType == 'device_command', onTap: () => setState(() => _actionType = 'device_command')),
            const SizedBox(height: 8),
            _OptionTile(title: 'Scene', subtitle: 'Activate a scene', icon: Icons.palette_rounded, selected: _actionType == 'scene', onTap: () => setState(() => _actionType = 'scene')),
          ],

          if (_step == 2) ...[
            Text('Step 3: Name & Confirm', style: AppTypography.displaySmall),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Automation Name', prefixIcon: Icon(Icons.label_rounded)),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            NestPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: AppTypography.labelSmall),
                  const SizedBox(height: 6),
                  Text('Trigger: $_triggerType${_triggerType == 'time' ? ' at ${_timeCtrl.text}' : ''}', style: AppTypography.bodySmall),
                  Text('Action: $_actionType', style: AppTypography.bodySmall),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      if (_nameCtrl.text.trim().isEmpty) return;
                      setState(() => _isSubmitting = true);
                      await widget.onSubmit(
                        _nameCtrl.text.trim(),
                        AutomationTrigger(
                          type: _triggerType,
                          config: _triggerType == 'time' ? {'time': _timeCtrl.text} : {},
                        ),
                        AutomationAction(type: _actionType, config: {}),
                      );
                    }
                  },
                  child: Text(_step < 2 ? 'Next' : 'Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.raised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge.copyWith(color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
