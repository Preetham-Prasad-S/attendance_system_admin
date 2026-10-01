import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/dashboard_entities.dart';
import 'trend_period_toggle.dart';

class AttendanceTrendCard extends StatelessWidget {
  const AttendanceTrendCard({
    super.key,
    required this.points,
    required this.period,
    required this.onPeriodChanged,
  });

  final List<DailyAttendancePoint> points;
  final TrendPeriod period;
  final ValueChanged<TrendPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final hasData = points.isNotEmpty;
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
                  TrendPeriodToggle(
                    selected: period,
                    onChanged: onPeriodChanged,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const _ChartLegend(),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 240,
            child: hasData
                ? Stack(
                    children: [
                      LineChart(_buildChartData(), duration: Duration.zero),
                      Positioned(top: 24, right: 48, child: _chartTooltip()),
                    ],
                  )
                : const _EmptyTrend(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FooterStats.forPoints(points: points, period: period),
        ],
      ),
    );
  }

  Widget _chartTooltip() {
    final last = points.last;
    final dayLabel = _isToday(last.date)
        ? 'Today'
        : DateFormat('MMM d').format(last.date);
    return _ChartTooltip(
      title: '$dayLabel: ${last.presentPct.toStringAsFixed(1)}%',
      subtitle: '${last.present} of ${last.total} present',
    );
  }

  LineChartData _buildChartData() {
    final minY = _minY();
    final labels = _buildLabels();
    final labelEvery = points.length <= 10 ? 1 : (points.length / 6).ceil();
    final lastX = points.length - 1;

    return LineChartData(
      minY: minY,
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
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= labels.length) {
                return const SizedBox.shrink();
              }
              if (index % labelEvery != 0 && index != lastX) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  labels[index],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(enabled: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            for (var i = 0; i < points.length; i++)
              FlSpot(i.toDouble(), points[i].presentPct),
          ],
          isCurved: true,
          barWidth: 3,
          color: AppColors.chartLine,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              color: index == lastX ? AppColors.success : AppColors.chartLine,
              radius: index == lastX ? 5.5 : 3.5,
              strokeColor: AppColors.surface,
              strokeWidth: 2,
            ),
          ),
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
  }

  double _minY() {
    var minPct = 100.0;
    for (final point in points) {
      minPct = math.min(minPct, point.presentPct);
    }
    if (minPct >= 70) return 70;
    final floored = (minPct / 10).floorToDouble() * 10;
    return floored < 0 ? 0 : floored;
  }

  List<String> _buildLabels() {
    final isShort = points.length <= 8;
    final lastIndex = points.length - 1;
    return [
      for (var i = 0; i < points.length; i++)
        i == lastIndex && _isToday(points[i].date)
            ? 'Today'
            : isShort
                ? '${DateFormat('EEE').format(points[i].date)} '
                      '(${DateFormat('MMM d').format(points[i].date)})'
                : DateFormat('MMM d').format(points[i].date),
    ];
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
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

class _EmptyTrend extends StatelessWidget {
  const _EmptyTrend();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No attendance data in this period yet.',
        style: AppTypography.caption.copyWith(fontSize: 12),
      ),
    );
  }
}

class _FooterStats extends StatelessWidget {
  const _FooterStats({
    required this.averageLabel,
    required this.averageValue,
    required this.peakValue,
    required this.totalLabel,
    required this.totalValue,
  });

  factory _FooterStats.forPoints({
    required List<DailyAttendancePoint> points,
    required TrendPeriod period,
  }) {
    if (points.isEmpty) {
      return _FooterStats(
        averageLabel: '${period.label} Average',
        averageValue: '—',
        peakValue: '—',
        totalLabel: 'Total Attendance Records',
        totalValue: '0',
      );
    }

    var pctSum = 0.0;
    var totalRecords = 0;
    var peak = points.first;
    for (final point in points) {
      pctSum += point.presentPct;
      totalRecords += point.total;
      if (point.presentPct > peak.presentPct) peak = point;
    }

    return _FooterStats(
      averageLabel: '${period.label} Average',
      averageValue: '${(pctSum / points.length).toStringAsFixed(1)}%',
      peakValue:
          '${DateFormat('EEEE').format(peak.date)} '
          '(${peak.presentPct.toStringAsFixed(1)}%)',
      totalLabel: 'Total Attendance Records',
      totalValue: totalRecords.toString(),
    );
  }

  final String averageLabel;
  final String averageValue;
  final String peakValue;
  final String totalLabel;
  final String totalValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: averageLabel,
              value: averageValue,
              valueColor: AppColors.textPrimary,
            ),
          ),
          _divider(),
          Expanded(
            child: _StatItem(
              label: 'Peak Turnout Day',
              value: peakValue,
              valueColor: AppColors.successDark,
            ),
          ),
          _divider(),
          Expanded(
            child: _StatItem(
              label: totalLabel,
              value: totalValue,
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
