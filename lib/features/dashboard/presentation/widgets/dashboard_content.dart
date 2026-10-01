import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'alerts/urgent_alerts_card.dart';
import 'analytics/department_breakdown_card.dart';
import 'analytics/presence_split_card.dart';
import 'charts/attendance_trend_card.dart';
import 'common/app_footer.dart';
import 'header/dashboard_header.dart';
import 'stats/kpi_stats_row.dart';
import 'table/roll_call_table_card.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const DashboardHeader(),
        const SizedBox(height: AppSpacing.xl),
        const KpiStatsRow(),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final unit = (constraints.maxWidth - AppSpacing.xl * 3) / 3;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: AttendanceTrendCard()),
                const SizedBox(width: AppSpacing.xl),
                SizedBox(width: unit, child: const UrgentAlertsCard()),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: DepartmentBreakdownCard()),
            SizedBox(width: AppSpacing.xl),
            Expanded(child: PresenceSplitCard()),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const RollCallTableCard(),
        const SizedBox(height: AppSpacing.xl),
        const AppFooter(),
      ],
    );
  }
}
