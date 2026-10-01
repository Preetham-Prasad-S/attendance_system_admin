import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/dashboard_entities.dart';

class UrgentAlertsCard extends StatelessWidget {
  const UrgentAlertsCard({super.key, required this.alerts});

  final List<DashboardAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final hasAlerts = alerts.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      hasAlerts
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 20,
                      color: hasAlerts
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Urgent Operational Alerts',
                        style: AppTypography.sectionTitle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 1,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: hasAlerts
                            ? AppColors.dangerSurface
                            : AppColors.successSurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        hasAlerts
                            ? '${alerts.length} Actionable'
                            : 'All Clear',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: hasAlerts
                              ? AppColors.dangerDark
                              : AppColors.successDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (!hasAlerts)
                  Text(
                    'No urgent alerts right now. All monitored attendance '
                    'signals are within limits.',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  )
                else
                  for (var i = 0; i < alerts.length; i++) ...[
                    if (i > 0) _divider(),
                    _AlertItem.fromAlert(alerts[i]),
                  ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: hasAlerts ? AppColors.danger : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Divider(height: 1, thickness: 1, color: AppColors.border),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.actionLabel,
    required this.actionStyle,
  });

  factory _AlertItem.fromAlert(DashboardAlert alert) => _AlertItem(
    type: alert.type,
    title: alert.title,
    description: alert.description,
    time: alert.time,
    actionLabel: alert.actionLabel,
    actionStyle: switch (alert.actionStyle) {
      AlertActionStyle.filled => _ActionStyle.filled,
      AlertActionStyle.outlined => _ActionStyle.outlined,
      AlertActionStyle.danger => _ActionStyle.danger,
    },
  );

  final String type;
  final String title;
  final String description;
  final String time;
  final String actionLabel;
  final _ActionStyle actionStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type,
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.danger,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(description, style: AppTypography.caption.copyWith(fontSize: 12)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Flexible(
              child: Text(
                time,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _actionButton(),
          ],
        ),
      ],
    );
  }

  Widget _actionButton() {
    final textStyle = AppTypography.caption.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    );

    switch (actionStyle) {
      case _ActionStyle.filled:
        return FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(padding: padding, textStyle: textStyle),
          child: Text(actionLabel),
        );
      case _ActionStyle.outlined:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: padding,
            textStyle: textStyle,
          ),
          child: Text(actionLabel),
        );
      case _ActionStyle.danger:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: padding,
            textStyle: textStyle,
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          child: Text(actionLabel),
        );
    }
  }
}

enum _ActionStyle { filled, outlined, danger }
