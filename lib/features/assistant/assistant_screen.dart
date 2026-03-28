import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'assistant_provider.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _quickCommands = [
    'Turn off all',
    'Night mode',
    'Status',
    'Morning',
    'Away mode',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    ref.read(assistantProvider.notifier).sendCommand(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(assistantProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Brain status header
          _BrainHeader(),

          // Message list
          Expanded(
            child: stateAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (_, __) => Center(child: Text('Failed to load history', style: AppTypography.bodySmall)),
              data: (state) => ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: state.messages.length,
                itemBuilder: (_, i) {
                  final msg = state.messages[i];
                  if (msg.isTypingIndicator) return const _TypingBubble();
                  return msg.isUser ? _UserBubble(message: msg.text, time: msg.timestamp) : _AiBubble(message: msg.text, devices: msg.devicesAffected, time: msg.timestamp);
                },
              ),
            ),
          ),

          // Quick command chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _quickCommands.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => ref.read(assistantProvider.notifier).sendCommand(_quickCommands[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.raised,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(_quickCommands[i], style: AppTypography.bodySmall),
                ),
              ),
            ),
          ),

          // Input row
          _InputRow(controller: _inputCtrl, onSend: _send),
        ],
      ),
    );
  }
}

class _BrainHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text('BRAIN ACTIVE', style: AppTypography.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 2)),
          const Spacer(),
          Text('v1.2.0-core', style: AppTypography.labelSmall.copyWith(fontSize: 9)),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  const _UserBubble({required this.message, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Text(message, style: AppTypography.bodyMedium.copyWith(color: AppColors.background, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                Text(_formatTime(time), style: AppTypography.inter(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AiBubble extends StatelessWidget {
  final String message;
  final List<String> devices;
  final DateTime time;
  const _AiBubble({required this.message, required this.devices, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.primary),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.raised.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(message, style: AppTypography.bodyMedium.copyWith(height: 1.5)),
                ),
                if (devices.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: devices.map((d) => _DeviceChip(label: d)).toList(),
                  ),
                ],
                const SizedBox(height: 4),
                Text(_formatTime(time), style: AppTypography.mono(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DeviceChip extends StatelessWidget {
  final String label;
  const _DeviceChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.developer_board_rounded, size: 10, color: AppColors.success),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.mono(fontSize: 10, color: AppColors.success)),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
            child: const Icon(Icons.psychology_rounded, size: 16, color: AppColors.primary),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
                  final bounce = (offset < 0.5 ? offset : 1.0 - offset) * 2;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6 + (bounce * 4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.4 + bounce * 0.6)),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputRow({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Ask NestShift Brain...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.raised,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            GestureDetector(
              onTap: onSend,
              child: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.background, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
