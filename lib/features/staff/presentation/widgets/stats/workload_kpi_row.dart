import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/features/dashboard/presentation/widgets/stats/kpi_stat_card.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';

/// The four workload KPI cards. Reuses the dashboard's [KpiStatCard] so both
/// screens stay visually identical; only the copy and accent tint differ.
///
/// Wraps to 2 columns below 1180px and 1 column below 560px.
class WorkloadKpiRow extends StatelessWidget {
  const WorkloadKpiRow({super.key, required this.kpis});

  final StaffKpis kpis;

  /// Below this width the four cards stop fitting side by side.
  static const double fourColumnBreakpoint = 1180;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.xl;
        final columns = switch (constraints.maxWidth) {
          > fourColumnBreakpoint => 4,
          > 560 => 2,
          _ => 1,
        };
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in _buildCards())
              SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  List<Widget> _buildCards() {
    final delta = kpis.attendanceTrendPercent.abs().toStringAsFixed(1);

    return [
      KpiStatCard(
        label: 'FACULTY ATTENDANCE',
        icon: Icons.how_to_reg_outlined,
        value: '${kpis.attendanceTrendPercent.toStringAsFixed(1)}%',
        badgeText: '+$delta%',
        badgeForeground: AppColors.successDark,
        badgeBackground: AppColors.successSurface,
        footer: StaffKpis.checkedInLabel(kpis),
        footerColor: AppColors.textSecondary,
        footerIcon: Icons.trending_up,
        accentColor: AppColors.success,
      ),
      KpiStatCard(
        label: 'CONDUCTED TODAY',
        icon: Icons.check_circle_outline,
        value: '${kpis.conductedToday}',
        progressValue: kpis.conductedRatio,
        footer:
            '${StaffKpis.conductedLabel(kpis)}'
            ' • ${kpis.inFlight} in-flight',
        footerColor: AppColors.textSecondary,
      ),
      KpiStatCard(
        label: 'FREE FACULTY NOW',
        icon: Icons.event_available_outlined,
        value: '${kpis.freeNow}',
        valueColor: AppColors.primaryLight,
        accentColor: AppColors.info,
        footer: '${kpis.onCampus} available for substitution',
        footerColor: AppColors.textSecondary,
        footerIcon: Icons.location_on_outlined,
      ),
      KpiStatCard(
        label: 'PENDING SUBSTITUTES',
        icon: Icons.swap_horiz,
        value: '${kpis.pendingSubstitutes}',
        valueColor: AppColors.warningDark,
        iconColor: AppColors.warning,
        accentColor: AppColors.warning,
        borderColor: AppColors.warning,
        footer: '${kpis.highPrioritySubstitutes} high resolve priority now →',
        footerColor: AppColors.warningDark,
        footerIcon: Icons.priority_high,
      ),
    ];
  }
}
