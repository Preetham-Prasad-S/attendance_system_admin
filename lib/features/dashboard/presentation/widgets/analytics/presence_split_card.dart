import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/dashboard_entities.dart';

class PresenceSplitCard extends StatelessWidget {
  const PresenceSplitCard({super.key, required this.kpis});

  final KpiStats kpis;

  double _percentOf(int count) =>
      kpis.recordsToday == 0 ? 0 : count / kpis.recordsToday * 100;

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
          Center(child: _DonutChart(kpis: kpis)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _LegendItem(
                  label: 'Present',
                  count: kpis.presentToday.toString(),
                  percent: '(${_percentOf(kpis.presentToday).toStringAsFixed(1)}%)',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _LegendItem(
                  label: 'Absent',
                  count: kpis.absentToday.toString(),
                  percent: '(${_percentOf(kpis.absentToday).toStringAsFixed(1)}%)',
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _LegendItem(
                  label: 'Late',
                  count: kpis.lateToday.toString(),
                  percent: '(${_percentOf(kpis.lateToday).toStringAsFixed(1)}%)',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _LegendItem(
                  label: 'Leave',
                  count: kpis.onLeaveToday.toString(),
                  percent: '(${_percentOf(kpis.onLeaveToday).toStringAsFixed(1)}%)',
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
  const _DonutChart({required this.kpis});

  final KpiStats kpis;

  @override
  Widget build(BuildContext context) {
    final sections = [
      if (kpis.presentToday > 0)
        PieChartSectionData(
          value: kpis.presentToday.toDouble(),
          color: AppColors.success,
          radius: 20,
          showTitle: false,
        ),
      if (kpis.absentToday > 0)
        PieChartSectionData(
          value: kpis.absentToday.toDouble(),
          color: AppColors.danger,
          radius: 20,
          showTitle: false,
        ),
      if (kpis.lateToday > 0)
        PieChartSectionData(
          value: kpis.lateToday.toDouble(),
          color: AppColors.warning,
          radius: 20,
          showTitle: false,
        ),
      if (kpis.onLeaveToday > 0)
        PieChartSectionData(
          value: kpis.onLeaveToday.toDouble(),
          color: AppColors.info,
          radius: 20,
          showTitle: false,
        ),
    ];

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
              sections: sections.isEmpty
                  ? [
                      PieChartSectionData(
                        value: 1,
                        color: AppColors.surfaceMuted,
                        radius: 20,
                        showTitle: false,
                      ),
                    ]
                  : sections,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kpis.totalStudents.toString(),
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
