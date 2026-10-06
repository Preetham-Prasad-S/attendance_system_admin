import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/students_entities.dart';
import '../common/compliance_chip.dart';

/// Overlay panel showing the selected student's summary, 30-day attendance
/// log, and placeholder sections (course deficit, parent contact).
///
/// The card shrink-wraps its content; [maxHeight] only caps it. When the
/// content is taller than the cap, the body scrolls internally.
class StudentDetailPanel extends StatelessWidget {
  const StudentDetailPanel({
    super.key,
    required this.entry,
    required this.log,
    required this.isLoadingLog,
    required this.maxHeight,
    required this.onClose,
  });

  final StudentDirectoryEntry entry;
  final List<AttendanceLogDay>? log;
  final bool isLoadingLog;

  /// Upper bound for the card's height; the card never exceeds it.
  final double maxHeight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final student = entry.student;
    final summary = entry.summary;
    final tier = summary.tier;
    final hasData = tier != ComplianceTier.noData;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(student, summary, tier, hasData),
            const Divider(height: 1, thickness: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SummaryStats(summary: summary, tier: tier),
                    const SizedBox(height: AppSpacing.lg),
                    _AttendanceLogCard(log: log, isLoading: isLoadingLog),
                    const SizedBox(height: AppSpacing.lg),
                    const _PlaceholderSection(
                      title: 'Course Attendance Deficit',
                      message:
                          'Per-course tracking requires the Subjects & '
                          'Timetable module, which is not available yet.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _PlaceholderSection(
                      title: 'Parent & Emergency Contact',
                      message:
                          'Parent contact details are not stored on the '
                          'student record yet.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: const Text('Dispatch Parent Warning SMS/Email'),
                      style: OutlinedButton.styleFrom(
                        disabledForegroundColor: AppColors.textMuted,
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    Student student,
    AttendanceSummary summary,
    ComplianceTier tier,
    bool hasData,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TierPalette.progress(tier), width: 2),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Text(
                student.initials,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sectionTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: TierPalette.chipBackground(tier),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: TierPalette.progress(tier)),
                      ),
                      child: Text(
                        hasData
                            ? '${summary.presentPct.toStringAsFixed(1)}%  '
                                  '${tier.chipLabel}'
                            : 'No data',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: TierPalette.foreground(tier),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Roll #${student.studentNo}  •  RFID: —',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  '${student.department ?? '—'}  •  '
                  '${student.isActive ? 'Active' : 'Inactive'}',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textMuted,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SummaryStats extends StatelessWidget {
  const _SummaryStats({required this.summary, required this.tier});

  final AttendanceSummary summary;
  final ComplianceTier tier;

  @override
  Widget build(BuildContext context) {
    final hasData = tier != ComplianceTier.noData;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'ATTENDANCE',
            value: hasData ? '${summary.presentPct.toStringAsFixed(1)}%' : '—',
            color: hasData ? TierPalette.foreground(tier) : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'SESSIONS',
            value: '${summary.attendedDays} / ${summary.requiredDays}',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(label: 'STATUS', value: tier.chipLabel),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.statLabel.copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceLogCard extends StatelessWidget {
  const _AttendanceLogCard({required this.log, required this.isLoading});

  final List<AttendanceLogDay>? log;
  final bool isLoading;

  static const _legend = [
    ('Present', AppColors.success),
    ('Late', AppColors.warning),
    ('Absent', AppColors.danger),
    ('Leave', AppColors.info),
    ('OFF', AppColors.textMuted),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  '30-Day Attendance Log',
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: 4,
                children: [
                  for (final (label, color) in _legend)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          label,
                          style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const SizedBox(
              height: 150,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (log == null || log!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No attendance records in the last 30 days.',
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            )
          else
            _buildGrid(log!),
        ],
      ),
    );
  }

  Widget _buildGrid(List<AttendanceLogDay> days) {
    final rows = <List<AttendanceLogDay>>[];
    for (var i = 0; i < days.length; i += 6) {
      rows.add(days.sublist(i, (i + 6).clamp(0, days.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 6),
          Row(
            children: [
              for (final day in rows[r]) ...[
                Expanded(child: _DayChip(day: day)),
                if (day != rows[r].last) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          _summaryLine(days),
          style: AppTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  static String _summaryLine(List<AttendanceLogDay> days) {
    int count(LogStatus status) =>
        days.where((day) => day.status == status).length;
    final parts = [
      '${count(LogStatus.present)} Present',
      '${count(LogStatus.late)} Late',
      '${count(LogStatus.absent)} Absent',
    ];
    final leave = count(LogStatus.onLeave);
    if (leave > 0) parts.add('$leave Leave');
    return 'Last 30 days: ${parts.join(' • ')}';
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day});

  final AttendanceLogDay day;

  @override
  Widget build(BuildContext context) {
    final isOff = day.status == LogStatus.off;
    final background = switch (day.status) {
      LogStatus.present => AppColors.success,
      LogStatus.late => AppColors.warning,
      LogStatus.absent => AppColors.danger,
      LogStatus.onLeave => AppColors.info,
      LogStatus.off => AppColors.surfaceMuted,
    };

    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        isOff ? 'OFF' : day.date.day.toString().padLeft(2, '0'),
        style: TextStyle(
          fontSize: isOff ? 9 : 12,
          fontWeight: FontWeight.w700,
          color: isOff ? AppColors.textMuted : AppColors.surface,
        ),
      ),
    );
  }
}

class _PlaceholderSection extends StatelessWidget {
  const _PlaceholderSection({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(message, style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
