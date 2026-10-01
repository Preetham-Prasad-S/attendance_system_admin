import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'kpi_stat_card.dart';

class KpiStatsRow extends StatelessWidget {
  const KpiStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: AppSpacing.lg);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: KpiStatCard(
              label: 'TOTAL STUDENTS',
              icon: Icons.people_outline,
              value: '4,850',
              footer: '+32 Registered this week',
              footerColor: AppColors.successDark,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'TOTAL STAFF',
              icon: Icons.badge_outlined,
              value: '342',
              footer: '98.2% on campus today',
              footerColor: AppColors.textSecondary,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'PRESENT TODAY',
              badgeText: '+1.5%',
              value: '92.4%',
              progressValue: 0.924,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'ABSENT TODAY',
              labelColor: AppColors.danger,
              icon: Icons.person_off_outlined,
              iconColor: AppColors.danger,
              value: '246',
              footer: 'Critical Defaulter Risk',
              footerColor: AppColors.danger,
              footerIcon: Icons.error_outline,
              accentColor: AppColors.danger,
            ),
          ),
          gap,
          Expanded(
            child: KpiStatCard(
              label: 'LATE ARRIVALS',
              icon: Icons.access_time,
              iconColor: AppColors.warning,
              value: '89',
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
              value: '34',
              footer: 'Medical / Duty Leaves',
              footerColor: AppColors.info,
              footerIcon: Icons.medical_services_outlined,
            ),
          ),
        ],
      ),
    );
  }
}
