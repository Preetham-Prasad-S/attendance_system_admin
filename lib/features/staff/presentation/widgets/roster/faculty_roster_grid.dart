import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';
import 'faculty_card.dart';

/// Responsive card grid for the roster. 2 columns at desktop, 1 below 760px.
class FacultyRosterGrid extends StatelessWidget {
  const FacultyRosterGrid({
    super.key,
    required this.faculty,
    required this.onDeploy,
    this.onReset,
  });

  final List<FacultyProfile> faculty;
  final void Function(FacultyProfile profile) onDeploy;

  /// Offered by the empty state; null hides the reset affordance.
  final VoidCallback? onReset;

  static const double twoColumnBreakpoint = 760;

  @override
  Widget build(BuildContext context) {
    if (faculty.isEmpty) {
      return _RosterEmptyState(onReset: onReset);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < twoColumnBreakpoint ? 1 : 2;
        const gap = AppSpacing.lg;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final member in faculty)
              SizedBox(
                width: cardWidth,
                child: FacultyCard(
                  key: ValueKey(member.id),
                  profile: member,
                  onDeploy: () => onDeploy(member),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RosterEmptyState extends StatelessWidget {
  const _RosterEmptyState({this.onReset});

  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_search_outlined,
            size: 34,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No faculty match these filters', style: AppTypography.body),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try a different department, designation, or status.',
            style: AppTypography.caption,
          ),
          if (onReset != null) ...[
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Reset Filters'),
            ),
          ],
        ],
      ),
    );
  }
}
