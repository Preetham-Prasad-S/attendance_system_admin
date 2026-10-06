import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/common/status_pill.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/coverage_alert_card.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/leave_approvals_summary.dart';
import 'package:attendance_system_admin/features/staff/presentation/widgets/coverage/sms_gateway_status.dart';
import 'package:flutter/material.dart';

/// The right-hand "Class Coverage Board" rail: uncovered lectures, leave
/// approvals, gateway health, and the daily report download.
///
/// On wide viewports it is a fixed-width sibling of the scrollable main column;
/// on narrow ones the page moves it below the roster.
class CoverageBoard extends StatelessWidget {
  const CoverageBoard({
    super.key,
    required this.alerts,
    required this.leaveApprovals,
    required this.totalLeaveApprovals,
    required this.onAssign,
    required this.onMerge,
    required this.onApproveLeave,
    required this.onRejectLeave,
    required this.onViewAllLeave,
    required this.onDownloadReport,
    this.scrollable = false,
  });

  final List<CoverageAlert> alerts;
  final List<LeaveApprovalStub> leaveApprovals;
  final int totalLeaveApprovals;

  /// `onAssign(alert)` — stub, no assignment flow exists yet.
  final void Function(CoverageAlert alert) onAssign;
  final void Function(CoverageAlert alert) onMerge;
  final void Function(LeaveApprovalStub request) onApproveLeave;
  final void Function(LeaveApprovalStub request) onRejectLeave;
  final VoidCallback onViewAllLeave;
  final VoidCallback onDownloadReport;

  /// Set when the rail sits in a height-constrained column (the desktop
  /// layout), so the board scrolls internally instead of overflowing. Left
  /// false when the page stacks the rail inside its own scroll view.
  final bool scrollable;

  /// Matches the reference's rail width. The parent constrains the board with
  /// this on wide viewports, or `double.infinity` when it is stacked below.
  static const double railWidth = 400;

  /// Below this the page stacks the rail under the roster instead.
  static const double stackBreakpoint = 1280;

  int get _urgentCount =>
      alerts.where((a) => a.severity == AlertSeverity.critical).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: scrollable
          ? SingleChildScrollView(child: _buildContent())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(
              Icons.dashboard_customize_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Class Coverage Board',
                    style: AppTypography.sectionTitle,
                  ),
                  Text(
                    'Active Gaps & Substitution Desk',
                    style: AppTypography.caption.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            if (_urgentCount > 0)
              StatusPill(
                label: '$_urgentCount Urgent',
                foreground: AppColors.dangerDark,
                background: AppColors.dangerSurface,
                borderColor: AppColors.danger,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        for (var i = 0; i < alerts.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          CoverageAlertCard(
            key: ValueKey(alerts[i].id),
            alert: alerts[i],
            onPrimaryAction: () => onAssign(alerts[i]),
            onSecondaryAction: () => onMerge(alerts[i]),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        LeaveApprovalsSummary(
          requests: leaveApprovals,
          totalPending: totalLeaveApprovals,
          onApprove: onApproveLeave,
          onReject: onRejectLeave,
          onViewAll: onViewAllLeave,
        ),
        const SizedBox(height: AppSpacing.lg),
        const SmsGatewayStatus(),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDownloadReport,
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 17),
            label: const Text('Download Daily Coverage Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              textStyle: AppTypography.button.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
