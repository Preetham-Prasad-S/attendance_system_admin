import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/common/status_pill.dart';
import 'package:flutter/material.dart';

/// One roster card. The 3px left rail and the session block tint both encode
/// [FacultyProfile.status], matching the design's status-driven cards.
class FacultyCard extends StatelessWidget {
  const FacultyCard({super.key, required this.profile, required this.onDeploy});

  final FacultyProfile profile;

  /// "Ready to Deploy" CTA — no deployment flow exists yet.
  final VoidCallback onDeploy;

  static const double accentWidth = 3;

  static Color railColorFor(FacultyStatus status) => switch (status) {
    FacultyStatus.inLecture => AppColors.primary,
    FacultyStatus.available => AppColors.success,
    FacultyStatus.onLeave => AppColors.warning,
  };

  static Color sessionBackgroundFor(FacultyProfile profile) =>
      profile.currentSession.isFreeBlock
      ? AppColors.infoSurface
      : AppColors.primaryMuted;

  static Color sessionForegroundFor(FacultyProfile profile) =>
      profile.currentSession.isFreeBlock
      ? AppColors.primaryLight
      : AppColors.primary;

  static Color sessionBorderFor(FacultyProfile profile) =>
      profile.currentSession.isFreeBlock
      ? const Color(0xFFBAE6FD)
      : const Color(0xFFC7D2FE);

  static (Color fg, Color bg) pillPalette(FacultyProfile profile) =>
      switch (profile.status) {
        FacultyStatus.inLecture => (AppColors.primary, AppColors.primaryMuted),
        FacultyStatus.available => (
          AppColors.successDark,
          AppColors.successSurface,
        ),
        FacultyStatus.onLeave => (
          AppColors.warningDark,
          AppColors.warningSurface,
        ),
      };

  /// Deterministic avatar tint — there are no photo assets in the repo.
  static Color avatarColorFor(String id) {
    const palette = [
      Color(0xFF6366F1),
      Color(0xFF0EA5E9),
      Color(0xFF14B8A6),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF8B5CF6),
    ];
    final hash = id.codeUnits.fold<int>(0, (a, b) => a + b);
    return palette[hash % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final rail = railColorFor(profile.status);
    final (pillFg, pillBg) = pillPalette(profile);
    final session = profile.currentSession;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onDeploy,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusRail(color: rail, profile: profile),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.name,
                            style: AppTypography.sectionTitle.copyWith(
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(profile.roleLine, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusPill(
                      label: profile.status.label,
                      foreground: pillFg,
                      background: pillBg,
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (profile.isHeadOfDepartment)
                      StatusPill(
                        label: 'HOD',
                        foreground: AppColors.primary,
                        background: AppColors.surface,
                        borderColor: AppColors.primarySurface,
                      ),
                    _GateInChip(gateIn: profile.gateIn),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SessionBlock(
                  session: session,
                  background: sessionBackgroundFor(profile),
                  foreground: sessionForegroundFor(profile),
                  border: sessionBorderFor(profile),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Daily Schedule Load',
                        style: AppTypography.caption,
                      ),
                    ),
                    Text(
                      profile.scheduleLoadLabel,
                      style: AppTypography.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: profile.scheduleRatio,
                    minHeight: 5,
                    color: rail,
                    backgroundColor: AppColors.surfaceMuted,
                  ),
                ),
                if (profile.isSubstitutable) ...[
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Ready to Deploy',
                      style: AppTypography.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3px vertical status bar with the gate indicator hanging off its base.
class _StatusRail extends StatelessWidget {
  const _StatusRail({required this.color, required this.profile});

  final Color color;
  final FacultyProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      height: 54,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: FacultyCard.accentWidth,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}

class _GateInChip extends StatelessWidget {
  const _GateInChip({required this.gateIn});

  final String gateIn;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.fingerprint, size: 13, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs + 1),
        Text(gateIn, style: AppTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}

/// The tinted block showing what the faculty member is doing right now.
class _SessionBlock extends StatelessWidget {
  const _SessionBlock({
    required this.session,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final FacultySession session;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: border),
      ),
      child: session.isFreeBlock
          ? _buildFreeBlock()
          : _buildLecture(foreground),
    );
  }

  Widget _buildFreeBlock() {
    return Row(
      children: [
        Icon(Icons.weekend_outlined, size: 16, color: foreground),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.availabilityLabel ?? session.code,
                style: AppTypography.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                session.slotLabel,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          'Ready to Deploy',
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.successDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLecture(Color foreground) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.meeting_room_outlined, size: 16, color: foreground),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                session.code,
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                session.venue,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          session.slotLabel,
          textAlign: TextAlign.right,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
