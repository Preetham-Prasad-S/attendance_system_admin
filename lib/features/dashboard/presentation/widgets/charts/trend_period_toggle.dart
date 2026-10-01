import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class TrendPeriodToggle extends StatefulWidget {
  const TrendPeriodToggle({super.key});

  @override
  State<TrendPeriodToggle> createState() => _TrendPeriodToggleState();
}

class _TrendPeriodToggleState extends State<TrendPeriodToggle> {
  static const _options = ['Weekly', 'Monthly', 'Semester'];

  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _options.length; i++)
            GestureDetector(
              onTap: () => setState(() => _selected = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  color: _selected == i
                      ? AppColors.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm - 2),
                  border: _selected == i
                      ? Border.all(color: AppColors.border)
                      : null,
                ),
                child: Text(
                  _options[i],
                  style: AppTypography.caption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _selected == i
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
