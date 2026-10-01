import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class UrgentAlertsCard extends StatelessWidget {
  const UrgentAlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Icon(
                      Icons.error_outline,
                      size: 20,
                      color: AppColors.danger,
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
                        color: AppColors.dangerSurface,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        '3 Actionable',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dangerDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _AlertItem(
                  type: 'THRESHOLD BREACH',
                  title: '18 Students below 75% in CS Dept',
                  description:
                      'Automated SMS warnings queued for parent dispatch.',
                  time: '10 mins ago',
                  actionLabel: 'Review & Notify Parents',
                  actionStyle: _ActionStyle.filled,
                ),
                _divider(),
                _AlertItem(
                  type: 'MISSING ROSTER',
                  title: 'Class 9-B (Period 3) - Physics',
                  description:
                      'Lecturer Prof. K. Mehta has not submitted session roster.',
                  time: '18 mins ago',
                  actionLabel: 'Ping Teacher',
                  actionStyle: _ActionStyle.outlined,
                ),
                _divider(),
                _AlertItem(
                  type: 'HARDWARE SIGNAL LOST',
                  title: 'Terminal 04 (North Gate - Face Rec)',
                  description:
                      'Offline for 12m. Optical scanner failing ping heartbeat.',
                  time: 'Heartbeat lost',
                  actionLabel: 'Run Diagnostics',
                  actionStyle: _ActionStyle.danger,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 4, color: AppColors.danger),
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

enum _ActionStyle { filled, outlined, danger }

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.actionLabel,
    required this.actionStyle,
  });

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
