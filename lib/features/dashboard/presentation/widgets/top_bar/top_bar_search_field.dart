import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class TopBarSearchField extends StatelessWidget {
  const TopBarSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showShortcut = constraints.maxWidth > 220;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.search, size: 17, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Search student roll number, staff ID or class',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (showShortcut) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm - 2),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '\u2318K',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
