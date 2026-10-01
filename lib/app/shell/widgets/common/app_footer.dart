import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppTypography.caption;
    final strong = AppTypography.caption.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.lg,
        runSpacing: AppSpacing.sm,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('CampusPulse', style: strong),
              Text('Version 4.8.2-Enterprise', style: muted),
              Text('•', style: muted),
              Text('ISO 27001 Certified Campus System', style: muted),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Authorized Operations', style: muted),
              Text('•', style: muted),
              Text('Session ID: #CP-884920', style: muted),
            ],
          ),
        ],
      ),
    );
  }
}
