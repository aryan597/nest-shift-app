import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/models/automation.dart';
import '../../features/hub/widgets/metallic_toggle.dart';
import 'automations_provider.dart';

class AutomationsScreen extends ConsumerWidget {
  const AutomationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;
    final automationsAsync = ref.watch(automationsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.cardRadius),
          boxShadow: style.hasGlow ? [
            BoxShadow(color: theme.primary.withValues(alpha: style.glowIntensity * 0.5), blurRadius: 12, spreadRadius: 0),
          ] : null,
        ),
        child: FloatingActionButton(
          elevation: 0,
          highlightElevation: 0,
          backgroundColor: theme.primary,
          foregroundColor: theme.background,
          onPressed: () => _showNewAutomationSheet(context, ref, theme, style),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(style.cardRadius)),
          child: Icon(Icons.add_rounded, size: style.iconSize + 4),
        ),
      ),
      body: automationsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: theme.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.warning, size: style.iconSize + 16),
              SizedBox(height: style.cardRadius),
              Text('Sync failed', style: AppTypography.displaySmall.copyWith(color: theme.textPrimary)),
              TextButton(
                onPressed: () => ref.refresh(automationsProvider),
                child: Text('Retry', style: TextStyle(color: theme.primary)),
              ),
            ],
          ),
        ),
        data: (automations) {
          if (automations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: style.iconSize * 2.5, color: theme.textMuted.withValues(alpha: 0.5)),
                  SizedBox(height: style.cardRadius * 1.5),
                  Text('No Flows Yet', style: AppTypography.displayMedium.copyWith(color: theme.textPrimary)),
                  SizedBox(height: style.cardRadius * 0.5),
                  Text('Automate your home with smart logic.', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: theme.primary,
            backgroundColor: theme.surface,
            onRefresh: () async {
              await ref.read(automationsProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.85),
              itemCount: automations.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(bottom: style.cardRadius * 0.75),
                child: _AutomationCard(
                  automation: automations[i],
                  theme: theme,
                  style: style,
                  onToggle: () => ref.read(automationsProvider.notifier).toggle(automations[i].id),
                  onTap: () => _showDetailSheet(context, ref, automations[i], theme, style),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, Automation automation, AppTheme theme, ThemeStyle style) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(style.cardRadius * 1.25)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(style.cardRadius * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(automation.name, style: AppTypography.displayMedium.copyWith(color: theme.textPrimary)),
            SizedBox(height: style.cardRadius * 0.5),
            Text('Trigger: ${automation.triggerDescription}', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
            SizedBox(height: style.cardRadius * 0.4),
            Text('Action: ${automation.actions.isNotEmpty ? automation.actions.first.type : 'none'}', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary)),
            SizedBox(height: style.cardRadius * 1.5),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    icon: Icon(Icons.delete_outline_rounded, size: style.iconSize * 0.65),
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

  void _showNewAutomationSheet(BuildContext context, WidgetRef ref, AppTheme theme, ThemeStyle style) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(style.cardRadius * 1.25)),
      ),
      builder: (_) => _NewAutomationSheet(theme: theme, style: style, onSubmit: (name, trigger, actions) async {
        await ref.read(automationsProvider.notifier).create(
          name: name,
          trigger: trigger,
          actions: actions,
        );
        if (context.mounted) Navigator.pop(context);
      }),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  final Automation automation;
  final AppTheme theme;
  final ThemeStyle style;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _AutomationCard({required this.automation, required this.theme, required this.style, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTimeBased = automation.trigger.type == 'time';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(style.cardRadius * 1.25),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(style.cardRadius),
          border: style.cardBorderWidth > 0 ? Border.all(color: theme.border) : null,
          boxShadow: style.hasGlow && automation.enabled ? [
            BoxShadow(color: theme.primary.withValues(alpha: style.glowIntensity * 0.25), blurRadius: 10, spreadRadius: 0),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: style.cardRadius * 3,
              height: style.cardRadius * 3,
              decoration: BoxDecoration(
                color: automation.enabled ? theme.primary.withValues(alpha: 0.1) : theme.surfaceRaised.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(style.cardRadius * 0.85),
              ),
              child: Icon(
                isTimeBased ? Icons.schedule_rounded : Icons.bolt_rounded,
                size: style.iconSize,
                color: automation.enabled ? theme.primary : theme.textMuted,
              ),
            ),
            SizedBox(width: style.cardRadius),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(automation.name, style: AppTypography.bodyLarge.copyWith(color: theme.textPrimary, fontWeight: FontWeight.w700)),
                  SizedBox(height: style.cardRadius * 0.25),
                  Text(automation.triggerDescription, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: theme.textSecondary)),
                ],
              ),
            ),
            SizedBox(width: style.cardRadius * 0.75),
            MetallicToggle(
              value: automation.enabled,
              small: true,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewAutomationSheet extends StatefulWidget {
  final AppTheme theme;
  final ThemeStyle style;
  final Future<void> Function(String name, AutomationTrigger trigger, List<AutomationAction> actions) onSubmit;

  const _NewAutomationSheet({required this.theme, required this.style, required this.onSubmit});

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
        left: widget.style.cardRadius * 1.5, right: widget.style.cardRadius * 1.5, top: widget.style.cardRadius * 1.5,
        bottom: MediaQuery.of(context).viewInsets.bottom + widget.style.cardRadius * 1.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? widget.style.cardRadius * 0.25 : 0),
                height: 3,
                decoration: BoxDecoration(
                  color: i <= _step ? widget.theme.primary : widget.theme.surfaceRaised,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
          ),
          SizedBox(height: widget.style.cardRadius * 1.25),

          if (_step == 0) ...[
            Text('Step 1: Choose Trigger', style: AppTypography.displaySmall.copyWith(color: widget.theme.textPrimary)),
            SizedBox(height: widget.style.cardRadius),
            _OptionTile(theme: widget.theme, style: widget.style, title: 'Time-based', subtitle: 'Runs at a specific time', icon: Icons.schedule_rounded, selected: _triggerType == 'time', onTap: () => setState(() => _triggerType = 'time')),
            SizedBox(height: widget.style.cardRadius * 0.5),
            _OptionTile(theme: widget.theme, style: widget.style, title: 'Device State', subtitle: 'Triggers when a device changes', icon: Icons.developer_board_rounded, selected: _triggerType == 'device_state', onTap: () => setState(() => _triggerType = 'device_state')),
            SizedBox(height: widget.style.cardRadius * 0.5),
            _OptionTile(theme: widget.theme, style: widget.style, title: 'Scene', subtitle: 'Activates on a scene trigger', icon: Icons.auto_awesome_rounded, selected: _triggerType == 'scene', onTap: () => setState(() => _triggerType = 'scene')),
            if (_triggerType == 'time') ...[
              SizedBox(height: widget.style.cardRadius * 0.75),
              TextField(
                controller: _timeCtrl,
                style: AppTypography.bodyMedium.copyWith(color: widget.theme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Time (HH:MM)',
                  labelStyle: AppTypography.labelSmall.copyWith(color: widget.theme.textMuted),
                  prefixIcon: Icon(Icons.access_time_rounded, color: widget.theme.textMuted, size: widget.style.iconSize),
                  filled: true,
                  fillColor: widget.theme.surfaceRaised,
                ),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ],

          if (_step == 1) ...[
            Text('Step 2: Choose Action', style: AppTypography.displaySmall.copyWith(color: widget.theme.textPrimary)),
            SizedBox(height: widget.style.cardRadius),
            _OptionTile(theme: widget.theme, style: widget.style, title: 'Device Command', subtitle: 'Turn a device on or off', icon: Icons.power_settings_new_rounded, selected: _actionType == 'device_command', onTap: () => setState(() => _actionType = 'device_command')),
            SizedBox(height: widget.style.cardRadius * 0.5),
            _OptionTile(theme: widget.theme, style: widget.style, title: 'Scene', subtitle: 'Activate a scene', icon: Icons.palette_rounded, selected: _actionType == 'scene', onTap: () => setState(() => _actionType = 'scene')),
          ],

          if (_step == 2) ...[
            Text('Step 3: Name & Confirm', style: AppTypography.displaySmall.copyWith(color: widget.theme.textPrimary)),
            SizedBox(height: widget.style.cardRadius),
            TextField(
              controller: _nameCtrl,
              style: AppTypography.bodyMedium.copyWith(color: widget.theme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Automation Name',
                labelStyle: AppTypography.labelSmall.copyWith(color: widget.theme.textMuted),
                prefixIcon: Icon(Icons.label_rounded, color: widget.theme.textMuted, size: widget.style.iconSize),
                filled: true,
                fillColor: widget.theme.surfaceRaised,
              ),
              autofocus: true,
            ),
            SizedBox(height: widget.style.cardRadius * 0.75),
            Container(
              padding: EdgeInsets.all(widget.style.cardRadius * 0.75),
              decoration: BoxDecoration(
                color: widget.theme.surfaceRaised,
                borderRadius: BorderRadius.circular(widget.style.cardRadius * 0.75),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Summary', style: AppTypography.labelSmall.copyWith(color: widget.theme.textMuted)),
                  SizedBox(height: widget.style.cardRadius * 0.4),
                  Text('Trigger: $_triggerType${_triggerType == 'time' ? ' at ${_timeCtrl.text}' : ''}', style: AppTypography.bodySmall.copyWith(color: widget.theme.textSecondary)),
                  Text('Action: $_actionType', style: AppTypography.bodySmall.copyWith(color: widget.theme.textSecondary)),
                ],
              ),
            ),
          ],

          SizedBox(height: widget.style.cardRadius * 1.5),
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.theme.textSecondary,
                      side: BorderSide(color: widget.theme.border),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) SizedBox(width: widget.style.cardRadius * 0.75),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () async {
                    if (_step < 2) {
                      setState(() => _step++);
                    } else {
                      if (_nameCtrl.text.trim().isEmpty) return;
                      setState(() => _isSubmitting = true);
                      final trigger = AutomationTrigger(
                        type: _triggerType,
                        config: _triggerType == 'time' ? {'cron': '0 ${_timeCtrl.text.split(':')[0]} * * *'} : {},
                      );
                      final actions = [
                        AutomationAction(
                          type: _actionType,
                          config: {'command': _actionType == 'device_command' ? 'turn_on' : 'activate', 'target': 'all_devices'},
                        ),
                      ];
                      await widget.onSubmit(_nameCtrl.text.trim(), trigger, actions);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primary,
                    foregroundColor: widget.theme.background,
                  ),
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
  final AppTheme theme;
  final ThemeStyle style;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({required this.theme, required this.style, required this.title, required this.subtitle, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(style.cardRadius),
        decoration: BoxDecoration(
          color: selected ? theme.primary.withValues(alpha: 0.08) : theme.surfaceRaised,
          borderRadius: BorderRadius.circular(style.cardRadius * 0.7),
          border: Border.all(color: selected ? theme.primary.withValues(alpha: 0.4) : theme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: style.iconSize * 0.85, color: selected ? theme.primary : theme.textMuted),
            SizedBox(width: style.cardRadius * 0.75),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.labelLarge.copyWith(color: selected ? theme.textPrimary : theme.textSecondary)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: theme.textMuted)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, size: style.iconSize * 0.75, color: theme.primary),
          ],
        ),
      ),
    );
  }
}