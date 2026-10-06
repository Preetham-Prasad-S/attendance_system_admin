import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';

/// Breadcrumb trail, page title/subtitle, the roster view-mode toggle, and
/// the Export Roster action.
class StaffPageHeader extends StatelessWidget {
  const StaffPageHeader({
    super.key,
    required this.kpis,
    required this.viewMode,
    required this.isExporting,
    required this.onViewModeChanged,
    required this.onExport,
  });

  final StaffKpis kpis;
  final StaffViewMode viewMode;
  final bool isExporting;
  final ValueChanged<StaffViewMode> onViewModeChanged;
  final VoidCallback onExport;

  static const List<String> _crumbs = [
    'Academic Affairs',
    'Faculty Operations',
    'Workload & Coverage',
  ];

  static IconData _iconFor(StaffViewMode mode) => switch (mode) {
    StaffViewMode.rosterGrid => Icons.grid_view_rounded,
    StaffViewMode.detailedTable => Icons.table_rows_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < _crumbs.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              Text(
                _crumbs[i],
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: i == _crumbs.length - 1
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: i == _crumbs.length - 1
                      ? AppColors.primaryLight
                      : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Faculty Workload & Lecture Coverage',
                    style: AppTypography.pageTitle,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Live tracking of ongoing classroom delivery, free '
                    'faculty capacity, and instant substitute deployment.',
                    style: AppTypography.pageSubtitle,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _MetaChip(
                        icon: Icons.groups_outlined,
                        label: '${kpis.facultyOnDuty} Faculty On Duty',
                      ),
                      const _MetaChip(
                        icon: Icons.sensors,
                        label: 'Gate Telemetry Live',
                        tone: _MetaTone.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewToggle(value: viewMode, onChanged: onViewModeChanged),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: isExporting ? null : onExport,
                      icon: isExporting
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_outlined, size: 17),
                      label: Text(isExporting ? 'Exporting…' : 'Export Roster'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Two-button segmented control for [StaffViewMode].
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.value, required this.onChanged});

  final StaffViewMode value;
  final ValueChanged<StaffViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in StaffViewMode.values)
            _ToggleSegment(
              mode: mode,
              isActive: mode == value,
              icon: StaffPageHeader._iconFor(mode),
              onTap: () => onChanged(mode),
            ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  const _ToggleSegment({
    required this.mode,
    required this.isActive,
    required this.icon,
    required this.onTap,
  });

  final StaffViewMode mode;
  final bool isActive;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm - 2),
            Text(
              mode.label,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _MetaTone { neutral, info, success }

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.tone = _MetaTone.neutral,
  });

  final IconData icon;
  final String label;
  final _MetaTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = switch (tone) {
      _MetaTone.neutral => (AppColors.textSecondary, AppColors.surfaceMuted),
      _MetaTone.info => (AppColors.primaryLight, AppColors.primaryMuted),
      _MetaTone.success => (AppColors.successDark, AppColors.successSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: AppSpacing.sm - 2),
          // The title column can get narrow next to the header actions, so the
          // label truncates rather than overflowing the chip.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
