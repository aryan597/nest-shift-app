import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/theme_provider.dart';
import '../../features/dashboard/brain_status_provider.dart';
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
    'Turn on all lights',
    'Turn off everything',
    'Toggle bedroom',
    'Status',
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
    final themeState = ref.watch(themeProvider);
    final theme = themeState.theme;
    final style = theme.style;
    final stateAsync = ref.watch(assistantProvider);

    return Scaffold(
      backgroundColor: theme.background,
      body: Column(
        children: [
          _BrainHeader(theme: theme, style: style),
          Expanded(
            child: stateAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: theme.primary)),
              error: (_, __) => Center(child: Text('Failed to load history', style: AppTypography.bodySmall.copyWith(color: theme.textSecondary))),
              data: (state) => ListView.builder(
                controller: _scrollCtrl,
                padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.85),
                itemCount: state.messages.length,
                itemBuilder: (_, i) {
                  final msg = state.messages[i];
                  if (msg.isTypingIndicator) return _TypingBubble(theme: theme, style: style);
                  return msg.isUser 
                      ? _UserBubble(message: msg.text, time: msg.timestamp, theme: theme, style: style)
                      : _AiBubble(message: msg.text, devices: msg.devicesAffected, time: msg.timestamp, theme: theme, style: style);
                },
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: 6),
              itemCount: _quickCommands.length,
              separatorBuilder: (_, __) => SizedBox(width: style.cardRadius * 0.5),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => ref.read(assistantProvider.notifier).sendCommand(_quickCommands[i]),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.4),
                  decoration: BoxDecoration(
                    color: theme.surfaceRaised,
                    borderRadius: BorderRadius.circular(style.cardRadius * 1.4),
                    border: style.cardBorderWidth > 0 ? Border.all(color: theme.border) : null,
                  ),
                  child: Text(_quickCommands[i], style: AppTypography.bodySmall.copyWith(color: theme.textPrimary)),
                ),
              ),
            ),
          ),
          _InputRow(controller: _inputCtrl, onSend: _send, theme: theme, style: style),
        ],
      ),
    );
  }
}

class _BrainHeader extends ConsumerWidget {
  final AppTheme theme;
  final ThemeStyle style;
  const _BrainHeader({required this.theme, required this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(brainStatusProvider);
    final isOnline = statusAsync.value?.isOnline ?? false;
    final mqttConnected = statusAsync.value?.mqttConnected ?? false;
    final apiReachable = statusAsync.value?.apiReachable ?? false;
    final whisperLoaded = statusAsync.value?.whisperLoaded ?? false;
    final uptimeSeconds = statusAsync.value?.uptimeSeconds ?? 0;
    final commandsToday = statusAsync.value?.commandsProcessedToday ?? 0;
    final lastCommand = statusAsync.value?.lastCommand;

    String uptimeStr;
    if (uptimeSeconds < 60) {
      uptimeStr = '${uptimeSeconds}s';
    } else if (uptimeSeconds < 3600) {
      uptimeStr = '${uptimeSeconds ~/ 60}m';
    } else {
      uptimeStr = '${uptimeSeconds ~/ 3600}h ${(uptimeSeconds % 3600) ~/ 60}m';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: style.cardRadius * 1.5, vertical: style.cardRadius),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: style.cardRadius,
            height: style.cardRadius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? theme.primary : AppColors.warning,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? theme.primary : AppColors.warning).withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: style.cardRadius),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isOnline ? 'BRAIN ACTIVE' : 'BRAIN OFFLINE',
                      style: AppTypography.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isOnline ? theme.primary : AppColors.warning,
                        letterSpacing: 2,
                      ),
                    ),
                    if (isOnline) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(uptimeStr, style: AppTypography.mono(fontSize: 9, color: theme.primary)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    _StatusDot(label: 'MQTT', active: mqttConnected, color: theme.primary),
                    SizedBox(width: 8),
                    _StatusDot(label: 'API', active: apiReachable, color: theme.accent),
                    SizedBox(width: 8),
                    _StatusDot(label: 'Voice', active: whisperLoaded, color: theme.accent),
                    if (commandsToday > 0) ...[
                      SizedBox(width: 8),
                      Text('$commandsToday cmd', style: AppTypography.labelSmall.copyWith(fontSize: 9, color: theme.textMuted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (lastCommand != null && lastCommand.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 10, color: theme.textMuted),
                  SizedBox(width: 4),
                  Text(lastCommand.length > 20 ? '${lastCommand.substring(0, 20)}...' : lastCommand, 
                       style: AppTypography.labelSmall.copyWith(fontSize: 9, color: theme.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  const _StatusDot({required this.label, required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : AppColors.textMuted,
          ),
        ),
        SizedBox(width: 3),
        Text(label, style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  final String message;
  final DateTime time;
  final AppTheme theme;
  final ThemeStyle style;
  const _UserBubble({required this.message, required this.time, required this.theme, required this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: style.cardRadius * 0.85),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.7),
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(style.cardRadius * 1.4),
                      topRight: Radius.circular(style.cardRadius * 1.4),
                      bottomLeft: Radius.circular(style.cardRadius * 1.4),
                    ),
                  ),
                  child: Text(message, style: AppTypography.bodyMedium.copyWith(color: theme.background, fontWeight: FontWeight.w600)),
                ),
                SizedBox(height: style.cardRadius * 0.4),
                Text(_formatTime(time), style: AppTypography.inter(fontSize: 10, color: theme.textMuted, fontWeight: FontWeight.w600)),
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
  final AppTheme theme;
  final ThemeStyle style;
  final bool isSuccess;
  const _AiBubble({required this.message, required this.devices, required this.time, required this.theme, required this.style, this.isSuccess = true});

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? theme.primary : AppColors.error;
    
    return Padding(
      padding: EdgeInsets.only(bottom: style.cardRadius * 0.85),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: style.cardRadius * 2,
            height: style.cardRadius * 2,
            margin: EdgeInsets.only(right: style.cardRadius * 0.55, top: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isSuccess ? Icons.check_rounded : Icons.warning_rounded,
              size: style.cardRadius,
              color: color,
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.7),
                  decoration: BoxDecoration(
                    color: theme.surfaceRaised.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(style.cardRadius * 1.4),
                      bottomLeft: Radius.circular(style.cardRadius * 1.4),
                      bottomRight: Radius.circular(style.cardRadius * 1.4),
                    ),
                  ),
                  child: Text(message, style: AppTypography.bodyMedium.copyWith(height: 1.5, color: theme.textPrimary)),
                ),
                if (devices.isNotEmpty) ...[
                  SizedBox(height: style.cardRadius * 0.4),
                  Wrap(
                    spacing: style.cardRadius * 0.4,
                    children: devices.map((d) => _DeviceChip(label: d, color: color, theme: theme, style: style)).toList(),
                  ),
                ],
                SizedBox(height: style.cardRadius * 0.25),
                Text(_formatTime(time), style: AppTypography.mono(fontSize: 10, color: theme.textMuted)),
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
  final Color color;
  final AppTheme theme;
  final ThemeStyle style;
  const _DeviceChip({required this.label, required this.color, required this.theme, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: style.cardRadius * 0.7, vertical: style.cardRadius * 0.25),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(style.cardRadius * 0.85),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.developer_board_rounded, size: style.cardRadius * 0.7, color: color),
          SizedBox(width: style.cardRadius * 0.25),
          Text(label, style: AppTypography.mono(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final AppTheme theme;
  final ThemeStyle style;
  const _TypingBubble({required this.theme, required this.style});

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
      padding: EdgeInsets.only(bottom: widget.style.cardRadius * 0.85),
      child: Row(
        children: [
          Container(
            width: widget.style.cardRadius * 2,
            height: widget.style.cardRadius * 2,
            margin: EdgeInsets.only(right: widget.style.cardRadius * 0.55),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.primary.withValues(alpha: 0.1),
              border: Border.all(color: widget.theme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.psychology_rounded, size: widget.style.cardRadius, color: widget.theme.primary),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: widget.style.cardRadius, vertical: widget.style.cardRadius),
            decoration: BoxDecoration(
              color: widget.theme.surface,
              border: widget.style.cardBorderWidth > 0 ? Border.all(color: widget.theme.border) : null,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(widget.style.cardRadius),
                bottomLeft: Radius.circular(widget.style.cardRadius),
                bottomRight: Radius.circular(widget.style.cardRadius),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
                  final bounce = (offset < 0.5 ? offset : 1.0 - offset) * 2;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: widget.style.cardRadius * 0.2),
                    width: widget.style.cardRadius * 0.4,
                    height: widget.style.cardRadius * 0.4 + (bounce * widget.style.cardRadius * 0.25),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.theme.primary.withValues(alpha: 0.4 + bounce * 0.6),
                    ),
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
  final AppTheme theme;
  final ThemeStyle style;
  const _InputRow({required this.controller, required this.onSend, required this.theme, required this.style});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(style.cardRadius, 8, style.cardRadius, style.cardRadius * 0.85),
        decoration: BoxDecoration(
          color: theme.surface,
          border: Border(top: BorderSide(color: theme.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTypography.bodyMedium.copyWith(color: theme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask NestShift Brain...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: theme.textMuted),
                  filled: true,
                  fillColor: theme.surfaceRaised,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(style.cardRadius * 0.7)),
                    borderSide: BorderSide(color: theme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(style.cardRadius * 0.7)),
                    borderSide: BorderSide(color: theme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(style.cardRadius * 0.7)),
                    borderSide: BorderSide(color: theme.primary.withValues(alpha: 0.6)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: style.cardRadius, vertical: style.cardRadius * 0.85),
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            SizedBox(width: style.cardRadius * 0.5),
            GestureDetector(
              onTap: onSend,
              child: Container(
                height: style.cardRadius * 3.4,
                width: style.cardRadius * 3.4,
                decoration: BoxDecoration(
                  color: theme.primary,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(style.cardRadius * 0.7)),
                  boxShadow: style.hasGlow ? [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: style.glowIntensity * 0.5),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: Icon(Icons.send_rounded, color: theme.background, size: style.iconSize - 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}