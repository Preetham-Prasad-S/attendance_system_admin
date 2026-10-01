import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class HeaderActionButtons extends StatelessWidget {
  const HeaderActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_calendar_outlined, size: 16),
              label: const Text('Mark Manual Attendance'),
            ),
            const SizedBox(width: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt, size: 17),
              label: const Text('Add Student'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined, size: 17),
              label: const Text('Generate Compliance Report'),
            ),
            const SizedBox(width: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.campaign_outlined, size: 17),
              label: const Text('Send Defaulter Notice'),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                textStyle: AppTypography.button,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
