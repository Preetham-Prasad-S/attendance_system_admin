import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';

/// Leave requests awaiting a coverage decision, with approve/reject stubs and
/// a "view all (n)" affordance for the Leave Approvals screen (not built yet).
class LeaveApprovalsSummary extends StatelessWidget {
  const LeaveApprovalsSummary({
    super.key,
    required this.requests,
    required this.totalPending,
    required this.onApprove,
    required this.onReject,
    required this.onViewAll,
  });

  final List<LeaveApprovalStub> requests;
  final int totalPending;

  final void Function(LeaveApprovalStub request) onApprove;
  final void Function(LeaveApprovalStub request) onReject;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'LEAVE APPROVALS SUMMARY',
                style: AppTypography.statLabel.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                child: Text(
                  'view all ($totalPending)',
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < requests.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _LeaveRow(
            request: requests[i],
            onApprove: () => onApprove(requests[i]),
            onReject: () => onReject(requests[i]),
          ),
        ],
      ],
    );
  }
}

class _LeaveRow extends StatelessWidget {
  const _LeaveRow({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final LeaveApprovalStub request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  request.facultyName,
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  request.reasonLine,
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 1),
                Text(
                  request.coverageLine,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: request.isCoverageWarning
                        ? AppColors.warningDark
                        : AppColors.successDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _DecisionButton(
            icon: Icons.check,
            background: AppColors.success,
            onPressed: onApprove,
            tooltip: 'Approve ${request.facultyName}',
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          _DecisionButton(
            icon: Icons.close,
            background: AppColors.surfaceMuted,
            foreground: AppColors.textSecondary,
            onPressed: onReject,
            tooltip: 'Reject ${request.facultyName}',
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.icon,
    required this.background,
    required this.onPressed,
    required this.tooltip,
    this.foreground = AppColors.surface,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}
