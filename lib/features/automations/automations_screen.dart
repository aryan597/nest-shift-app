import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/automation.dart';
import '../../shared/widgets/nest_panel.dart';
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: () => _showNewAutomationSheet(context, ref),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: automationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load automations', style: AppTypography.bodySmall)),
        data: (automations) {
          if (automations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No automations yet', style: AppTypography.exo(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Tap + to create your first automation', style: AppTypography.bodySmall),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(automationsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
            Text(automation.name, style: AppTypography.orbitron(fontSize: 18)),
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
    return NestPanel(
      glowColor: automation.enabled ? AppColors.primary : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: automation.enabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.raised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: automation.enabled ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
                ),
                child: Icon(
                  isTimeBased ? Icons.schedule_rounded : Icons.bolt_rounded,
                  size: 22,
                  color: automation.enabled ? AppColors.primary : AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(automation.name, style: AppTypography.exo(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(automation.triggerDescription, style: AppTypography.bodySmall),
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
            Text('Step 1: Choose Trigger', style: AppTypography.orbitron(fontSize: 14)),
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
            Text('Step 2: Choose Action', style: AppTypography.orbitron(fontSize: 14)),
            const SizedBox(height: 16),
            _OptionTile(title: 'Device Command', subtitle: 'Turn a device on or off', icon: Icons.power_settings_new_rounded, selected: _actionType == 'device_command', onTap: () => setState(() => _actionType = 'device_command')),
            const SizedBox(height: 8),
            _OptionTile(title: 'Scene', subtitle: 'Activate a scene', icon: Icons.palette_rounded, selected: _actionType == 'scene', onTap: () => setState(() => _actionType = 'scene')),
          ],

          if (_step == 2) ...[
            Text('Step 3: Name & Confirm', style: AppTypography.orbitron(fontSize: 14)),
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
                  Text(title, style: AppTypography.exo(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
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
