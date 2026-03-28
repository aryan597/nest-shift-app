import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/models/insight.dart';
import '../../shared/widgets/nest_panel.dart';
import 'insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  Color _severityColor(InsightSeverity s) {
    switch (s) {
      case InsightSeverity.warning:
        return AppColors.warning;
      case InsightSeverity.suggestion:
        return AppColors.accent;
      case InsightSeverity.info:
        return AppColors.primary;
    }
  }

  IconData _severityIcon(InsightSeverity s) {
    switch (s) {
      case InsightSeverity.warning:
        return Icons.warning_amber_rounded;
      case InsightSeverity.suggestion:
        return Icons.auto_awesome_rounded;
      case InsightSeverity.info:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'AI ', style: AppTypography.orbitron(fontSize: 18, color: AppColors.primary)),
            TextSpan(text: 'Insights', style: AppTypography.orbitron(fontSize: 18, color: AppColors.textPrimary)),
          ]),
        ),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => ref.read(insightsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Failed to load insights', style: AppTypography.bodySmall)),
        data: (insights) {
          if (insights.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      'No insights yet',
                      style: AppTypography.exo(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep devices active to generate AI suggestions',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () => ref.read(insightsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: insights.length,
              itemBuilder: (_, i) {
                final insight = insights[i];
                final color = _severityColor(insight.severity);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NestPanel(
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left severity border
                          Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(_severityIcon(insight.severity), size: 18, color: color),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          insight.title,
                                          style: AppTypography.exo(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      ),
                                      if (insight.isResolved)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.success.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                                              const SizedBox(width: 4),
                                              Text('Resolved', style: AppTypography.mono(fontSize: 10, color: AppColors.success)),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(insight.description, style: AppTypography.bodySmall),
                                  if (!insight.isResolved && (insight.isSuggestion || insight.isWarning)) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (insight.isSuggestion)
                                          FilledButton.tonalIcon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                                              foregroundColor: AppColors.accent,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.check_rounded, size: 14),
                                            label: Text('Approve', style: AppTypography.exo(fontSize: 12, fontWeight: FontWeight.w600)),
                                            onPressed: () async {
                                              try {
                                                await ref.read(insightsProvider.notifier).approve(insight.id);
                                              } catch (_) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to approve', style: AppTypography.exo(fontSize: 13)), backgroundColor: AppColors.raised),
                                                  );
                                                }
                                              }
                                            },
                                          ),
                                        if (insight.isWarning)
                                          FilledButton.tonalIcon(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                                              foregroundColor: AppColors.warning,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.flash_on_rounded, size: 14),
                                            label: Text('Fix Now', style: AppTypography.exo(fontSize: 12, fontWeight: FontWeight.w600)),
                                            onPressed: () async {
                                              try {
                                                await ref.read(insightsProvider.notifier).fixNow(insight.id);
                                              } catch (_) {}
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
