import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../hub/hub_provider.dart';

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(width: 3, height: 40, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: AppTypography.bodySmall)),
        ]),
        backgroundColor: AppColors.raised,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── ADD PIN DIALOG ─────────────────────────────────────────────────────────
  void _showAddPinDialog(BuildContext context, WidgetRef ref, int pin) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PinDialogBody(
        title: 'Add Pin GPIO-$pin',
        subtitle: 'Register this pin as a device',
        nameController: nameController,
        submitLabel: 'Add Device',
        onSubmit: (name, type) async {
          Navigator.pop(ctx);
          try {
            await ref
                .read(gpioPinsProvider.notifier)
                .registerPin(pin, name, type);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pin GPIO-$pin registered as $name'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) _showError(context, 'Failed to register pin');
          }
        },
        onError: (msg) => _showError(context, msg),
      ),
    );
  }

  // ── EDIT PIN DIALOG ────────────────────────────────────────────────────────
  void _showEditPinDialog(BuildContext context, WidgetRef ref, GpioPin pin) {
    final nameController = TextEditingController(text: pin.name ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PinDialogBody(
        title: 'Edit GPIO-${pin.pin}',
        subtitle: 'Update pin configuration',
        nameController: nameController,
        initialType: pin.deviceType ?? 'relay',
        submitLabel: 'Save Changes',
        onSubmit: (name, type) async {
          Navigator.pop(ctx);
          try {
            await ref
                .read(gpioPinsProvider.notifier)
                .updatePinConfig(pin.pin, name, type, room: pin.room);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('GPIO-${pin.pin} updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) _showError(context, 'Failed to update pin');
          }
        },
        onError: (msg) => _showError(context, msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinsAsync = ref.watch(gpioPinsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pinsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.warning, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load pins', style: AppTypography.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(gpioPinsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (pins) {
          final registeredPins = pins.where((p) => p.isRegistered).toList();
          final unregisteredPins = pins.where((p) => !p.isRegistered).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(gpioPinsProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ─── REGISTERED PINS ─────────────────────────────────────
                if (registeredPins.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text('ACTIVE PINS',
                              style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.success, letterSpacing: 2)),
                          const Spacer(),
                          Text('Tap to edit',
                              style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PinCard(
                            pin: registeredPins[i],
                            // FIX 1: call togglePin — not registerPin
                            onToggle: registeredPins[i].deviceType == 'relay'
                                ? (newVal) async {
                                    HapticFeedback.mediumImpact();
                                    try {
                                      await ref
                                          .read(gpioPinsProvider.notifier)
                                          .togglePin(
                                              registeredPins[i].pin, newVal);
                                    } catch (_) {
                                      if (context.mounted) {
                                        _showError(
                                            context, 'Failed to toggle device');
                                      }
                                    }
                                  }
                                : null,
                            // FIX 2: open edit sheet on tap
                            onTap: () => _showEditPinDialog(
                                context, ref, registeredPins[i]),
                          ),
                        ),
                        childCount: registeredPins.length,
                      ),
                    ),
                  ),
                ],

                // ─── UNREGISTERED PINS ────────────────────────────────────
                if (unregisteredPins.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: AppColors.textMuted,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text('AVAILABLE PINS',
                              style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.textMuted, letterSpacing: 2)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _UnregisteredPinCard(
                            pin: unregisteredPins[i],
                            onAdd: () => _showAddPinDialog(
                                context, ref, unregisteredPins[i].pin),
                          ),
                        ),
                        childCount: unregisteredPins.length,
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (pins.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.developer_board_outlined,
                              size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 20),
                          Text('No GPIO pins detected',
                              style: AppTypography.displaySmall),
                          const SizedBox(height: 8),
                          Text('Connect your NestShift hub to see pins',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── SHARED DIALOG BODY ────────────────────────────────────────────────────────
// FIX 3: Made a proper StatefulWidget so setState() rebuilds the chips.

class _PinDialogBody extends StatefulWidget {
  final String title;
  final String subtitle;
  final TextEditingController nameController;
  final String initialType;
  final String submitLabel;
  final Future<void> Function(String name, String type) onSubmit;
  final void Function(String msg) onError;

  const _PinDialogBody({
    required this.title,
    required this.subtitle,
    required this.nameController,
    required this.submitLabel,
    required this.onSubmit,
    required this.onError,
    this.initialType = 'relay',
  });

  @override
  State<_PinDialogBody> createState() => _PinDialogBodyState();
}

class _PinDialogBodyState extends State<_PinDialogBody> {
  late String _selectedType;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(widget.title, style: AppTypography.displayMedium),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: widget.nameController,
            decoration: const InputDecoration(
              labelText: 'Device Name',
              hintText: 'e.g., Living Room Light',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 20),
          Text('Device Type', style: AppTypography.labelLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TypeChip(
                label: 'Relay',
                icon: Icons.electric_bolt,
                isSelected: _selectedType == 'relay',
                onTap: () => setState(() => _selectedType = 'relay'),
              ),
              _TypeChip(
                label: 'Sensor',
                icon: Icons.sensors,
                isSelected: _selectedType == 'sensor',
                onTap: () => setState(() => _selectedType = 'sensor'),
              ),
              _TypeChip(
                label: 'Soil',
                icon: Icons.water_drop,
                isSelected: _selectedType == 'soil',
                onTap: () => setState(() => _selectedType = 'soil'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (widget.nameController.text.trim().isEmpty) {
                        widget.onError('Please enter a device name');
                        return;
                      }
                      setState(() => _loading = true);
                      await widget.onSubmit(
                          widget.nameController.text.trim(), _selectedType);
                      if (mounted) setState(() => _loading = false);
                    },
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PIN CARDS ──────────────────────────────────────────────────────────────────

class _PinCard extends StatelessWidget {
  final GpioPin pin;
  final Function(bool)? onToggle;
  final VoidCallback? onTap;

  const _PinCard({required this.pin, this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = pin.state ?? false;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOn
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isOn ? AppColors.primary : AppColors.textMuted)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                pin.deviceType == 'sensor'
                    ? Icons.sensors
                    : pin.deviceType == 'soil'
                        ? Icons.water_drop
                        : Icons.electric_bolt,
                color: isOn ? AppColors.primary : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pin.name ?? 'GPIO ${pin.pin}',
                      style: AppTypography.bodyMedium),
                  Text(
                    'GPIO ${pin.pin} • ${pin.deviceType ?? 'relay'}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            // Relay → show toggle; sensor → show edit icon
            if (onToggle != null)
              Switch(
                value: isOn,
                onChanged: onToggle,
                activeThumbColor: AppColors.primary,
              )
            else
              const Icon(Icons.edit_outlined,
                  color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _UnregisteredPinCard extends StatelessWidget {
  final GpioPin pin;
  final VoidCallback onAdd;

  const _UnregisteredPinCard({required this.pin, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.add_circle_outline, color: AppColors.textMuted),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GPIO ${pin.pin}', style: AppTypography.bodyMedium),
                  Text('Tap to add as device',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label,
      required this.icon,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? AppColors.primary : AppColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
