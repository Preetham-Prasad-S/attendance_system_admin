import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class RollCallTableCard extends StatelessWidget {
  const RollCallTableCard({super.key});

  static final _headerStyle = AppTypography.caption.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Recent Roll-Call Submissions (Live Sessions)',
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Cross-departmental section sheets finalized within current hour',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Showing 4 of 64 Classes', style: AppTypography.caption),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.chartLine,
                    ),
                    child: const Text('Export Daily CSV'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Class & Batch', style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Instructor In-Charge', style: _headerStyle),
                ),
                Expanded(flex: 2, child: Text('Subject', style: _headerStyle)),
                Expanded(
                  flex: 2,
                  child: Text('Turnout Ratio', style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Attendance %',
                    textAlign: TextAlign.center,
                    style: _headerStyle,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Submission Method', style: _headerStyle),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Audit Action', style: _headerStyle),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          _RollCallRow(
            className: 'CS-4A (Sem 7)',
            instructor: 'Dr. Ramesh Chandra',
            subject: 'Distributed Systems',
            turnout: '68 / 70',
            percent: '97.1%',
            percentColor: AppColors.successDark,
            percentBackground: AppColors.successSurface,
            method: 'Automated Bio Kiosk',
            action: 'View Sheet',
          ),
          const Divider(height: 1, thickness: 1),
          _RollCallRow(
            className: 'ME-2B (Sem 4)',
            instructor: 'Prof. Alok Verma',
            subject: 'Fluid Mechanics',
            turnout: '54 / 62',
            percent: '87.0%',
            percentColor: AppColors.info,
            percentBackground: AppColors.infoSurface,
            method: 'Teacher Portal Entry',
            action: 'View Sheet',
          ),
          const Divider(height: 1, thickness: 1),
          _RollCallRow(
            className: 'EC-3A (Sem 6)',
            instructor: 'Dr. Vandana Rao',
            subject: 'VLSI Design Lab',
            turnout: '42 / 44',
            percent: '95.4%',
            percentColor: AppColors.successDark,
            percentBackground: AppColors.successSurface,
            method: 'RFID Station #06',
            action: 'View Sheet',
          ),
          const Divider(height: 1, thickness: 1),
          _RollCallRow(
            className: 'CE-1C (Sem 2)',
            instructor: 'Prof. Tariq Mansoor',
            subject: 'Surveying Theory',
            turnout: '39 / 55',
            percent: '70.9%',
            percentColor: AppColors.warningDark,
            percentBackground: AppColors.warningSurface,
            method: 'Manual Attendance Override',
            action: 'Flag Low Turnout',
            flagAction: true,
          ),
        ],
      ),
    );
  }
}

class _RollCallRow extends StatelessWidget {
  const _RollCallRow({
    required this.className,
    required this.instructor,
    required this.subject,
    required this.turnout,
    required this.percent,
    required this.percentColor,
    required this.percentBackground,
    required this.method,
    required this.action,
    this.flagAction = false,
  });

  final String className;
  final String instructor;
  final String subject;
  final String turnout;
  final String percent;
  final Color percentColor;
  final Color percentBackground;
  final String method;
  final String action;
  final bool flagAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              className,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              instructor,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              subject,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  turnout,
                  style: AppTypography.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Present',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _AttendanceChip(
                percent: percent,
                color: percentColor,
                background: percentBackground,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              method,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              action,
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: flagAction
                    ? AppColors.warningDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  const _AttendanceChip({
    required this.percent,
    required this.color,
    required this.background,
  });

  final String percent;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            percent,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
