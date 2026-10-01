import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class DepartmentBreakdownCard extends StatelessWidget {
  const DepartmentBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Text(
                  'Department Breakdown',
                  style: AppTypography.sectionTitle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Filter Classes',
                  style: AppTypography.caption.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.chartLine,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Real-time attendance efficiency indexed by academic division',
            style: AppTypography.caption.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.xl),
          _DepartmentRow(
            name: 'Electronics & Comm. (ECE)',
            value: 96.0,
            color: AppColors.primary,
          ),
          _gap(),
          _DepartmentRow(
            name: 'Computer Science & Eng.',
            value: 95.0,
            color: AppColors.primaryLight,
          ),
          _gap(),
          _DepartmentRow(
            name: 'Electrical Engineering',
            value: 93.0,
            color: AppColors.chartLine,
          ),
          _gap(),
          _DepartmentRow(
            name: 'Mechanical Engineering',
            value: 91.0,
            color: AppColors.info,
          ),
          _gap(),
          _DepartmentRow(
            name: 'Biotechnology',
            value: 89.0,
            color: AppColors.chartLineLight,
          ),
          _gap(),
          _DepartmentRow(
            name: 'Civil & Environmental',
            value: 88.0,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'Total 8 Active Faculties',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View Master Roster \u2192',
                    style: AppTypography.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.chartLine,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(height: AppSpacing.lg + 4);
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + 1),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 7,
            color: color,
            backgroundColor: AppColors.surfaceMuted,
          ),
        ),
      ],
    );
  }
}
