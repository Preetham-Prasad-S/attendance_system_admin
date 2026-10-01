import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'header_action_buttons.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: AppSpacing.sm,
                spacing: AppSpacing.lg,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Thursday, October 24, 2024',
                        style: AppTypography.label.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successSurface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Academic Sessions Active',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.successDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Executive Attendance Overview',
                style: AppTypography.pageTitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'High-volume biometric streams, terminal operational '
                'telemetry, and faculty roll call metrics.',
                style: AppTypography.pageSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        const HeaderActionButtons(),
      ],
    );
  }
}
