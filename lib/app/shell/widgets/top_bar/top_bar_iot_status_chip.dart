import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class TopBarIotStatusChip extends StatelessWidget {
  const TopBarIotStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.router_outlined,
            size: 15,
            color: AppColors.successDark,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '24/26 IoT Terminals Live',
            style: AppTypography.label.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.successDark,
            ),
          ),
        ],
      ),
    );
  }
}
