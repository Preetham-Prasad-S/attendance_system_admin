import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) return _buildLoaded(context, state);
        if (state is DashboardFailureState) {
          return _DashboardError(message: state.message);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildLoaded(BuildContext context, DashboardLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const DashboardHeader(),
        const SizedBox(height: AppSpacing.xl),
        KpiStatsRow(kpis: state.kpis, trend: state.trend),
        const SizedBox(height: AppSpacing.xl),
        LayoutBuilder(
          builder: (context, constraints) {
            final unit = (constraints.maxWidth - AppSpacing.xl * 3) / 3;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AttendanceTrendCard(
                    points: state.trend,
                    period: state.period,
                    onPeriodChanged: (period) => context
                        .read<DashboardBloc>()
                        .add(TrendPeriodChanged(period: period)),
                  ),
                ),
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

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Failed to load dashboard data',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => context
                .read<DashboardBloc>()
                .add(LoadDashboardRequested()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
