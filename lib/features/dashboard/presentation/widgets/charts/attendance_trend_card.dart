import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import 'trend_period_toggle.dart';

class AttendanceTrendCard extends StatelessWidget {
  const AttendanceTrendCard({super.key});

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Campus-Wide Attendance Trend',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tracking daily student turnouts against institutional '
                      '75% compliance threshold',
                      style: AppTypography.caption.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      'Live Averaged',
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TrendPeriodToggle(),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _ChartLegend(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                LineChart(_chartData, duration: Duration.zero),
                Positioned(
                  top: 24,
                  right: 48,
                  child: _ChartTooltip(
                    title: 'Today: 92.4%',
                    subtitle: '4,481 of 4,850 present',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _FooterStats(),
        ],
      ),
    );
  }

  static final _chartData = LineChartData(
    minY: 70,
    maxY: 100,
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 10,
    ),
    titlesData: FlTitlesData(
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          reservedSize: 34,
          getTitlesWidget: _bottomTitle,
        ),
      ),
    ),
    lineTouchData: LineTouchData(enabled: false),
    borderData: FlBorderData(show: false),
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 87.5),
          FlSpot(1, 91.0),
          FlSpot(2, 90.4),
          FlSpot(3, 94.1),
          FlSpot(4, 92.4),
        ],
        isCurved: true,
        barWidth: 3,
        color: AppColors.chartLine,
        dotData: FlDotData(getDotPainter: _dotPainter),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x474F46E5), Color(0x004F46E5)],
          ),
        ),
      ),
    ],
    extraLinesData: ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: 75,
          color: AppColors.chartThreshold,
          strokeWidth: 1.5,
          dashArray: [6, 5],
          label: HorizontalLineLabel(
            show: true,
            labelResolver: _thresholdLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.chartThreshold,
            ),
            alignment: Alignment.topRight,
          ),
        ),
      ],
    ),
  );

  static Widget _bottomTitle(double value, TitleMeta meta) {
    const labels = [
      'Fri (Oct 18)',
      'Mon (Oct 21)',
      'Tue (Oct 22)',
      'Wed (Oct 23)',
      'Thu (Today)',
    ];
    final index = value.toInt();
    if (index < 0 || index >= labels.length) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        labels[index],
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
    );
  }

  static FlDotPainter _dotPainter(
    FlSpot spot,
    double percent,
    LineChartBarData bar,
    int index,
  ) {
    final isToday = spot.x == 4;
    return FlDotCirclePainter(
      color: isToday ? AppColors.success : AppColors.chartLine,
      radius: isToday ? 5.5 : 3.5,
      strokeColor: AppColors.surface,
      strokeWidth: 2,
    );
  }

  static String _thresholdLabel(HorizontalLine line) => '75% Min Target';
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.chartLine,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Actual Daily Attendance %',
          style: AppTypography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        const _DashedIndicator(),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Mandatory Threshold (75.0%)',
          style: AppTypography.caption.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.chartThreshold,
          ),
        ),
      ],
    );
  }
}

class _DashedIndicator extends StatelessWidget {
  const _DashedIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: 5,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.chartThreshold,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          if (i < 3) const SizedBox(width: 3),
        ],
      ],
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterStats extends StatelessWidget {
  const _FooterStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _StatItem(
              label: 'Weekly Average',
              value: '91.2%',
              valueColor: AppColors.textPrimary,
            ),
          ),
          _divider(),
          const Expanded(
            child: _StatItem(
              label: 'Peak Turnout Day',
              value: 'Thursday (92.4%)',
              valueColor: AppColors.successDark,
            ),
          ),
          _divider(),
          const Expanded(
            child: _StatItem(
              label: 'Total Bio Scans Processed',
              value: '38,912',
              valueColor: AppColors.chartLine,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: AppColors.border,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.sectionTitle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
