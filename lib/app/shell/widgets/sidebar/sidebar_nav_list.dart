import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'sidebar_nav_item.dart';

/// Sidebar navigation.
///
/// Built from a descriptor list rather than a hardcoded column so entries can
/// be role-gated (Institutes is super-admin only) without duplicating the
/// whole column. `AppShell` indexes its page list by the same positions, so
/// the order here defines the page index.
class SidebarNavList extends StatelessWidget {
  const SidebarNavList({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.isSuperAdmin = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Gates the Institutes entry; a regular admin never sees it.
  final bool isSuperAdmin;

  static const int institutesIndex = 9;

  static List<_NavEntry> _entries() => [
    _NavEntry(
      index: 0,
      icon: Icons.dashboard_outlined,
      label: 'Dashboard',
      isEnabled: true,
    ),
    _NavEntry(
      index: 1,
      icon: Icons.people_outline,
      label: 'Students',
      isEnabled: true,
    ),
    _NavEntry(
      index: 2,
      icon: Icons.badge_outlined,
      label: 'Staff/Faculty',
      isEnabled: true,
      showLivePill: true,
    ),
    const _NavEntry(
      index: 3,
      icon: Icons.calendar_month_outlined,
      label: 'Timetable',
    ),
    const _NavEntry(
      index: 4,
      icon: Icons.fact_check_outlined,
      label: 'Daily Attendance',
    ),
    const _NavEntry(
      index: 5,
      icon: Icons.event_available_outlined,
      label: 'Leave Approvals',
      trailingCount: '12',
    ),
    const _NavEntry(
      index: 6,
      icon: Icons.insights_outlined,
      label: 'Analytics & Reports',
    ),
    const _NavEntry(
      index: 7,
      icon: Icons.hub_outlined,
      label: 'Device Hub',
      showStatusDot: true,
    ),
    const _NavEntry(
      index: 8,
      icon: Icons.notifications_outlined,
      label: 'Notifications',
    ),
    const _NavEntry(
      index: institutesIndex,
      icon: Icons.apartment_outlined,
      label: 'Institutes',
      isEnabled: true,
      superAdminOnly: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in _entries()) ...[
          if (entry.superAdminOnly && !isSuperAdmin)
            const SizedBox.shrink()
          else
            SidebarNavItem(
              icon: entry.icon,
              label: entry.label,
              isActive: selectedIndex == entry.index,
              trailing: entry.trailingCount != null
                  ? _NavBadge(count: entry.trailingCount!)
                  : (entry.showStatusDot ? const _NavDot() : null),
              activeTrailing: entry.showLivePill ? const _LivePill() : null,
              // Placeholder screens are not selectable yet.
              onTap: entry.isEnabled ? () => onSelect(entry.index) : null,
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _NavEntry {
  const _NavEntry({
    required this.index,
    required this.icon,
    required this.label,
    this.isEnabled = false,
    this.superAdminOnly = false,
    this.trailingCount,
    this.showStatusDot = false,
    this.showLivePill = false,
  });

  final int index;
  final IconData icon;
  final String label;

  /// Wired to a real page in [AppShell].
  final bool isEnabled;

  /// Only rendered for a super admin.
  final bool superAdminOnly;
  final String? trailingCount;
  final bool showStatusDot;

  /// Shows a green "Live" pill in the item's selected state only.
  final bool showLivePill;
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

/// Green "Live" pill shown on the active nav item (Staff/Faculty).
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 1,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        'Live',
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.surface,
        ),
      ),
    );
  }
}
