import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/dashboard_entities.dart';
import 'kpi_stat_card.dart';

class KpiStatsRow extends StatelessWidget {
  const KpiStatsRow({super.key, required this.kpis, required this.trend});

  final KpiStats kpis;
  final List<DailyAttendancePoint> trend;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: AppSpacing.lg);

    final presentPct = kpis.presentTodayPct;
    final delta = _todayDelta;
    final deltaText = delta == null
        ? null
        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%';
    final deltaDown = (delta ?? 0) < 0;
    final hasAbsentees = kpis.absentToday > 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: KpiStatCard(
              label: 'TOTAL STUDENTS',
              icon: Icons.people_outline,
              value: kpis.totalStudents.toString(),
              footer: kpis.departmentCount > 0
                  ? 'Across ${kpis.departmentCount} departments'
                  : 'Active roster',
              footerColor: AppColors.textSecondary,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'TOTAL STAFF',
              icon: Icons.badge_outlined,
              value: kpis.totalStaff.toString(),
              footer: 'Faculty & support directory',
              footerColor: AppColors.textSecondary,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'PRESENT TODAY',
              badgeText: deltaText,
              badgeForeground: deltaDown
                  ? AppColors.dangerDark
                  : AppColors.successDark,
              badgeBackground: deltaDown
                  ? AppColors.dangerSurface
                  : AppColors.successSurface,
              value: '${presentPct.toStringAsFixed(1)}%',
              progressValue: (presentPct / 100).clamp(0.0, 1.0),
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'ABSENT TODAY',
              labelColor: hasAbsentees
                  ? AppColors.danger
                  : AppColors.textMuted,
              icon: Icons.person_off_outlined,
              iconColor: hasAbsentees ? AppColors.danger : AppColors.textMuted,
              value: kpis.absentToday.toString(),
              footer: hasAbsentees
                  ? 'Critical Defaulter Risk'
                  : 'No defaulters today',
              footerColor: hasAbsentees
                  ? AppColors.danger
                  : AppColors.textSecondary,
              footerIcon: hasAbsentees ? Icons.error_outline : null,
              accentColor: hasAbsentees ? AppColors.danger : null,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'LATE ARRIVALS',
              icon: Icons.access_time,
              iconColor: AppColors.warning,
              value: kpis.lateToday.toString(),
              footer: 'Past 08:30 AM Cutoff',
              footerColor: AppColors.warningDark,
              footerIcon: Icons.schedule,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'ON LEAVE',
              icon: Icons.event_available_outlined,
              iconColor: AppColors.info,
              value: kpis.onLeaveToday.toString(),
              footer: 'Medical / Duty Leaves',
              footerColor: AppColors.info,
              footerIcon: Icons.medical_services_outlined,
            ),
          ),
        ],
      ),
    );
  }

  /// Change of today's present percentage against yesterday, if available.
  double? get _todayDelta {
    if (trend.length < 2) return null;
    final today = trend.last;
    if (!_isToday(today.date)) return null;
    final yesterday = trend[trend.length - 2];
    return today.presentPct - yesterday.presentPct;
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
