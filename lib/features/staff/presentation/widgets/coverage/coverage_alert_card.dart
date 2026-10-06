import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/common/status_pill.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/roster/faculty_card.dart';
import 'package:flutter/material.dart';

/// One Class Coverage Board alert: an unattended or at-risk lecture.
///
/// Severity drives the frame, the severity strip, and which action row shows.
class CoverageAlertCard extends StatelessWidget {
  const CoverageAlertCard({
    super.key,
    required this.alert,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final CoverageAlert alert;

  /// "Assign & SMS"
  final VoidCallback onPrimaryAction;

  /// "Merge Session" — only rendered for [CoverageStage.recommended].
  final VoidCallback onSecondaryAction;

  bool get _isCritical => alert.severity == AlertSeverity.critical;

  Color get _accent =>
      _isCritical ? AppColors.dangerDark : AppColors.warningDark;

  Color get _frame => _isCritical ? AppColors.danger : AppColors.warning;

  Color get _surface =>
      _isCritical ? const Color(0xFFFFF7F7) : const Color(0xFFFFFBF2);

  Color get _stripTextColor =>
      _isCritical ? AppColors.surface : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _frame),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: _SeverityStrip(
                        alert: alert,
                        textColor: _stripTextColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        alert.timeRange,
                        textAlign: TextAlign.right,
                        style: AppTypography.caption.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _accent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${alert.courseCode}: ${alert.courseTitle}',
                  style: AppTypography.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.venueLine,
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
                if (alert.noticeLead != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _NoticeBlock(
                    icon: alert.noticeIcon,
                    lead: alert.noticeLead!,
                    body: alert.noticeBody ?? '',
                    accent: _accent,
                    frame: _frame,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _SubstituteBlock(alert: alert),
              ],
            ),
          ),
          _ActionRow(
            alert: alert,
            onPrimaryAction: onPrimaryAction,
            onSecondaryAction: onSecondaryAction,
          ),
        ],
      ),
    );
  }
}

/// Solid severity chip, e.g. "UNATTENDED NOW" / "UPCOMING (IN 45M)".
class _SeverityStrip extends StatelessWidget {
  const _SeverityStrip({required this.alert, required this.textColor});

  final CoverageAlert alert;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.severity == AlertSeverity.critical;
    final label = alert.countdownLabel.isEmpty
        ? alert.badgeLabel
        : '${alert.badgeLabel} ${alert.countdownLabel}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isCritical ? AppColors.danger : AppColors.warning,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
    );
  }
}

/// Tinted callout explaining why the session is uncovered.
class _NoticeBlock extends StatelessWidget {
  const _NoticeBlock({
    required this.icon,
    required this.lead,
    required this.body,
    required this.accent,
    required this.frame,
  });

  final IconData? icon;
  final String lead;
  final String body;
  final Color accent;
  final Color frame;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: frame),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.caption.copyWith(fontSize: 12),
                children: [
                  TextSpan(
                    text: '$lead: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recommended (with syllabus match) or already-assigned substitute.
class _SubstituteBlock extends StatelessWidget {
  const _SubstituteBlock({required this.alert});

  final CoverageAlert alert;

  bool get _isRecommended => alert.stage == CoverageStage.recommended;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _isRecommended
                      ? 'Recommended Substitute:'
                      : 'Assigned Substitute:',
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
              ),
              if (_isRecommended && alert.substituteMatchPercent != null)
                StatusPill(
                  label: '${alert.substituteMatchPercent}% Syllabus Match',
                  foreground: AppColors.successDark,
                  background: AppColors.successSurface,
                )
              else if (!_isRecommended)
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 13, color: AppColors.successDark),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Accepted SMS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: FacultyCard.avatarColorFor(
                  alert.substituteName ?? alert.id,
                ),
                child: Text(
                  facultyInitials(alert.substituteName ?? ''),
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
                      alert.substituteName ?? '—',
                      style: AppTypography.label.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      alert.substituteMeta ?? '',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (!_isRecommended)
                const Icon(
                  Icons.check_circle_outline,
                  size: 17,
                  color: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Assign + Merge buttons (recommended) or the assignment receipt (assigned).
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.alert,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  final CoverageAlert alert;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    if (alert.stage == CoverageStage.assigned) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.sms_outlined,
              size: 15,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Substitute notified — no action needed.',
                style: AppTypography.caption.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPrimaryAction,
              icon: const Icon(Icons.send_outlined, size: 15),
              label: const Text('Assign & SMS'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                textStyle: AppTypography.button.copyWith(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                textStyle: AppTypography.button.copyWith(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              child: const Text('Merge Session'),
            ),
          ),
        ],
      ),
    );
  }
}
