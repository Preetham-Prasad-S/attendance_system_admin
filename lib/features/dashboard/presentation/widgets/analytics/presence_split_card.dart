import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class PresenceSplitCard extends StatelessWidget {
  const PresenceSplitCard({super.key});

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
                  'Presence Split Ratio',
                  style: AppTypography.sectionTitle,
                ),
              ),
              const Icon(
                Icons.settings_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Holistic headcount status for roll calls conducted',
            style: AppTypography.caption.copyWith(fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(child: _DonutChart()),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              const Expanded(
                child: _LegendItem(
                  label: 'Present',
                  count: '4,481',
                  percent: '(92.4%)',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(
                child: _LegendItem(
                  label: 'Absent',
                  count: '246',
                  percent: '(5.1%)',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Expanded(
                child: _LegendItem(
                  label: 'Late',
                  count: '89',
                  percent: '(1.8%)',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const Expanded(
                child: _LegendItem(
                  label: 'Leave',
                  count: '34',
                  percent: '(0.7%)',
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            width: double.infinity,
            child: Text(
              'Accredited in compliance with UGC & State Attendance Guidelines',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 75,
              sections: [
                PieChartSectionData(
                  value: 4481,
                  color: AppColors.success,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 246,
                  color: AppColors.danger,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 89,
                  color: AppColors.warning,
                  radius: 20,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 34,
                  color: AppColors.info,
                  radius: 20,
                  showTitle: false,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '4,850',
                style: AppTypography.sectionTitle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'TOTAL STDS',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.count,
    required this.percent,
    required this.color,
  });

  final String label;
  final String count;
  final String percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(percent, style: AppTypography.caption.copyWith(fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
