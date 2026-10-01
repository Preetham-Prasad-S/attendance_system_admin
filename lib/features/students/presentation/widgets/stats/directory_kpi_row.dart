import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../domain/entities/students_entities.dart';
import '../../../../dashboard/presentation/widgets/stats/kpi_stat_card.dart';

/// 4 KPI cards: Total Enrolled / Compliant / Defaulters / Critical Warning.
class DirectoryKpiRow extends StatelessWidget {
  const DirectoryKpiRow({super.key, required this.kpis});

  final DirectoryKpis kpis;

  static String _pct(double value) => '${value.toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.xl;
        final columns = constraints.maxWidth < 900 ? 2 : 4;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        final cards = [
          KpiStatCard(
            label: 'TOTAL ENROLLED',
            icon: Icons.people_outline,
            value: kpis.totalEnrolled.toString(),
            badgeText: kpis.newThisTerm > 0 ? '+${kpis.newThisTerm} this term' : null,
            badgeForeground: AppColors.primaryLight,
            badgeBackground: AppColors.primarySurface,
            footer: 'Active semester rosters verified',
            footerColor: AppColors.textSecondary,
          ),
          KpiStatCard(
            label: 'COMPLIANT (>75%)',
            icon: Icons.verified_outlined,
            iconColor: AppColors.success,
            value: kpis.compliantCount.toString(),
            badgeText: _pct(kpis.compliantPct),
            badgeForeground: AppColors.successDark,
            badgeBackground: AppColors.successSurface,
            footer: 'Eligible for terminal examinations',
            footerColor: AppColors.textSecondary,
          ),
          KpiStatCard(
            label: 'ATTENDANCE DEFAULTERS (<75%)',
            icon: Icons.warning_amber_outlined,
            iconColor: AppColors.warning,
            value: kpis.defaulterCount.toString(),
            valueColor: AppColors.danger,
            badgeText: _pct(kpis.defaulterPct),
            badgeForeground: AppColors.warningDark,
            badgeBackground: AppColors.warningSurface,
            footer: 'Notice Queued • SMS alerts scheduled',
            footerColor: AppColors.dangerDark,
          ),
          KpiStatCard(
            label: 'CRITICAL WARNING (<65%)',
            icon: Icons.error_outline,
            iconColor: AppColors.danger,
            value: kpis.criticalCount.toString(),
            valueColor: AppColors.danger,
            badgeText: _pct(kpis.criticalPct),
            badgeForeground: AppColors.dangerDark,
            badgeBackground: AppColors.dangerSurface,
            footer: 'Deans list debarrment warning',
            footerColor: AppColors.dangerDark,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}
