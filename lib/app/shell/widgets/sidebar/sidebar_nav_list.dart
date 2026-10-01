import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'sidebar_nav_item.dart';

class SidebarNavList extends StatelessWidget {
  const SidebarNavList({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarNavItem(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          isActive: selectedIndex == 0,
          onTap: () => onSelect(0),
        ),
        const SizedBox(height: AppSpacing.xs),
        SidebarNavItem(
          icon: Icons.people_outline,
          label: 'Students',
          isActive: selectedIndex == 1,
          onTap: () => onSelect(1),
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.badge_outlined,
          label: 'Staff/Faculty',
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.calendar_month_outlined,
          label: 'Timetable',
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.fact_check_outlined,
          label: 'Daily Attendance',
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.event_available_outlined,
          label: 'Leave Approvals',
          trailing: _NavBadge(count: '12'),
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.insights_outlined,
          label: 'Analytics & Reports',
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.hub_outlined,
          label: 'Device Hub',
          trailing: _NavDot(),
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
        ),
        const SizedBox(height: AppSpacing.xs),
        const SidebarNavItem(
          icon: Icons.settings_outlined,
          label: 'System Settings',
        ),
      ],
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({required this.count});

  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        count,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.warningDark,
        ),
      ),
    );
  }
}

class _NavDot extends StatelessWidget {
  const _NavDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
