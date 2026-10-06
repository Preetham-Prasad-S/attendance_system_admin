import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/common/status_pill.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_card.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_roster_grid.dart';
import 'package:flutter/material.dart';

/// Dense tabular alternative to the roster grid, toggled from the page header.
///
/// Hand-built `Row` + `Expanded(flex:)` columns rather than [DataTable], which
/// cannot render per-cell pills without a custom builder on every column.
class FacultyDetailedTable extends StatelessWidget {
  const FacultyDetailedTable({
    super.key,
    required this.faculty,
    required this.onDeploy,
    this.onReset,
  });

  final List<FacultyProfile> faculty;
  final void Function(FacultyProfile profile) onDeploy;
  final VoidCallback? onReset;

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  static const TextStyle _tabularStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    if (faculty.isEmpty) {
      return FacultyRosterGrid(
        faculty: faculty,
        onDeploy: onDeploy,
        onReset: onReset,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: const _HeaderRow(),
          ),
          for (final member in faculty) ...[
            Divider(height: 1, thickness: 1, color: AppColors.border),
            _FacultyRow(profile: member, onDeploy: () => onDeploy(member)),
          ],
          Divider(height: 1, thickness: 1, color: AppColors.border),
          _TableFooter(count: faculty.length),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 4,
          child: Text('FACULTY', style: FacultyDetailedTable._headerStyle),
        ),
        const Expanded(
          flex: 3,
          child: Text('DEPARTMENT', style: FacultyDetailedTable._headerStyle),
        ),
        const Expanded(
          flex: 3,
          child: Text(
            'CURRENT SESSION',
            style: FacultyDetailedTable._headerStyle,
          ),
        ),
        const Expanded(
          flex: 2,
          child: Text('GATE IN', style: FacultyDetailedTable._headerStyle),
        ),
        const Expanded(
          flex: 2,
          child: Text('SESSIONS', style: FacultyDetailedTable._headerStyle),
        ),
        const Expanded(
          flex: 2,
          child: Text('STATUS', style: FacultyDetailedTable._headerStyle),
        ),
      ],
    );
  }
}

class _FacultyRow extends StatelessWidget {
  const _FacultyRow({required this.profile, required this.onDeploy});

  final FacultyProfile profile;
  final VoidCallback onDeploy;

  @override
  Widget build(BuildContext context) {
    final (pillFg, pillBg) = FacultyCard.pillPalette(profile);

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onDeploy,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 30,
                      decoration: BoxDecoration(
                        color: FacultyCard.railColorFor(profile.status),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: FacultyCard.avatarColorFor(profile.id),
                      child: Text(
                        profile.initials,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: FacultyDetailedTable._tabularStyle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            profile.designation,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  profile.department,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  profile.currentSession.isFreeBlock
                      ? 'Free — ${profile.currentSession.availabilityLabel ?? 'on campus'}'
                      : '${profile.currentSession.code} · ${profile.currentSession.venue}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FacultyDetailedTable._tabularStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FacultyCard.sessionForegroundFor(profile),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  profile.gateIn,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${profile.sessionsCompleted}/${profile.sessionsTotal}',
                  style: FacultyDetailedTable._tabularStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusPill(
                    label: profile.status.label,
                    foreground: pillFg,
                    background: pillBg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  const _TableFooter({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            'Showing all $count faculty members',
            style: AppTypography.caption,
          ),
          const Spacer(),
          const Icon(Icons.info_outline, size: 13, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Static demo data — not yet synced to Supabase',
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
