import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/students_entities.dart';
import '../common/compliance_chip.dart';

/// Paginated student roster: header, rows (identity, department, telemetry,
/// compliance bar, sessions, status chip) and the pagination footer.
class StudentsTableCard extends StatelessWidget {
  const StudentsTableCard({
    super.key,
    required this.page,
    required this.filters,
    required this.selectedStudentId,
    required this.onSelect,
    required this.onClearSelection,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final DirectoryPage page;
  final DirectoryFilters filters;
  final String? selectedStudentId;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearSelection;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, thickness: 1),
          if (page.entries.isEmpty)
            const _EmptyState()
          else
            for (var i = 0; i < page.entries.length; i++) ...[
              if (i > 0) const Divider(height: 1, thickness: 1),
              _StudentRow(
                entry: page.entries[i],
                selected: page.entries[i].student.id == selectedStudentId,
                onSelect: onSelect,
                onClearSelection: onClearSelection,
              ),
            ],
          const Divider(height: 1, thickness: 1),
          _PaginationFooter(
            page: filters.page,
            pageSize: filters.pageSize,
            totalCount: page.totalCount,
            onPageChanged: onPageChanged,
            onPageSizeChanged: onPageSizeChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const SizedBox(
            width: 28,
            child: Checkbox(value: false, onChanged: null),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(flex: 4, child: Text('STUDENT', style: _headerStyle)),
          const Expanded(
            flex: 2,
            child: Text('DEPARTMENT & CLASS', style: _headerStyle),
          ),
          const Expanded(
            flex: 2,
            child: Text('BIO / RFID TELEMETRY', style: _headerStyle),
          ),
          const Expanded(
            flex: 3,
            child: Text('OVERALL ATTENDANCE', style: _headerStyle),
          ),
          const Expanded(
            flex: 2,
            child: Text('SESSIONS', style: _headerStyle),
          ),
          const Expanded(
            flex: 2,
            child: Text('STATUS', style: _headerStyle),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.entry,
    required this.selected,
    required this.onSelect,
    required this.onClearSelection,
  });

  final StudentDirectoryEntry entry;
  final bool selected;
  final ValueChanged<String> onSelect;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    final student = entry.student;
    final summary = entry.summary;
    final tier = summary.tier;
    final foreground = TierPalette.foreground(tier);
    final hasData = tier != ComplianceTier.noData;

    return Material(
      color: selected ? AppColors.primaryMuted : AppColors.surface,
      child: InkWell(
        onTap: selected
            ? onClearSelection
            : () => onSelect(student.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 28,
                child: Checkbox(
                  value: selected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => selected
                      ? onClearSelection()
                      : onSelect(student.id),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _avatarColor(student.name),
                      child: Text(
                        student.initials,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
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
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningSurface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    'Selected',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.warningDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: student.studentNo,
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (student.email != null &&
                                    student.email!.isNotEmpty) ...[
                                  TextSpan(
                                    text: '  •  ${student.email}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      student.department ?? '—',
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sem — • Sec —',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      student.isActive ? 'Active' : 'Inactive',
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: _TelemetryCell(
                  lastMethod: entry.lastMethod,
                  lastRecordedAt: entry.lastRecordedAt,
                  color: foreground,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          hasData
                              ? '${summary.presentPct.toStringAsFixed(1)}%'
                              : '—',
                          style: AppTypography.body.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: hasData
                                ? foreground
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.full,
                            ),
                            child: LinearProgressIndicator(
                              value: hasData
                                  ? (summary.presentPct / 100)
                                        .clamp(0.0, 1.0)
                                  : 0,
                              minHeight: 6,
                              color: TierPalette.progress(tier),
                              backgroundColor: AppColors.surfaceMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 68,
                          child: Text(
                            tier.label,
                            textAlign: TextAlign.right,
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: hasData
                                  ? foreground
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Text(
                  '${summary.attendedDays} / ${summary.requiredDays}',
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(flex: 2, child: ComplianceChip(tier: tier)),
            ],
          ),
        ),
      ),
    );
  }

  /// Deterministic avatar tint derived from the student's name.
  static Color _avatarColor(String name) {
    const palette = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.info,
      AppColors.successDark,
      AppColors.warningDark,
    ];
    var hash = 0;
    for (final code in name.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }
}

class _TelemetryCell extends StatelessWidget {
  const _TelemetryCell({
    required this.lastMethod,
    required this.lastRecordedAt,
    required this.color,
  });

  final String? lastMethod;
  final DateTime? lastRecordedAt;
  final Color color;

  static const _methodLabels = {
    'rfid': 'RFID Gate',
    'biometric': 'Biometric Kiosk',
    'manual': 'Manual Entry',
    'qr': 'QR Scan',
    'portal': 'Faculty Portal',
  };

  String _dayLabel(DateTime recorded) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(recorded.year, recorded.month, recorded.day);
    final diffDays = today.difference(day).inDays;
    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    return '$diffDays days ago';
  }

  @override
  Widget build(BuildContext context) {
    final recorded = lastRecordedAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RFID: —',
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        if (recorded == null) ...[
          const SizedBox(height: 2),
          Text(
            'No check-ins yet',
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
        ] else ...[
          const SizedBox(height: 2),
          Text(
            _dayLabel(recorded),
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatTime(recorded),
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            _methodLabels[lastMethod?.toLowerCase()] ??
                _capitalize(lastMethod) ??
                '—',
            style: AppTypography.caption.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  static String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String? _capitalize(String? value) {
    if (value == null || value.isEmpty) return null;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.person_search_outlined,
              size: 40,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No students match the current filters',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try adjusting the search or clearing a filter.',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  static const _pageSizes = [10, 25, 50, 100];

  int get _totalPages =>
      totalCount == 0 ? 1 : ((totalCount + pageSize - 1) ~/ pageSize);

  /// Page buttons with `null` entries marking skipped ranges, e.g.
  /// `[0, null, 4, 5, 6, null, 23]`.
  static List<int?> _visiblePages(int current, int total) {
    if (total <= 7) return [for (var i = 0; i < total; i++) i];
    final pages = <int>{0, total - 1, current, current - 1, current + 1}
        .where((p) => p >= 0 && p < total)
        .toList()
      ..sort();
    final result = <int?>[];
    for (var i = 0; i < pages.length; i++) {
      if (i > 0 && pages[i] - pages[i - 1] > 1) result.add(null);
      result.add(pages[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _totalPages;
    final current = page.clamp(0, totalPages - 1);
    final from = totalCount == 0 ? 0 : current * pageSize + 1;
    final to = ((current + 1) * pageSize).clamp(0, totalCount);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: AppSpacing.sm,
        spacing: AppSpacing.lg,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Showing $from–$to of $totalCount students',
                style: AppTypography.caption.copyWith(fontSize: 13),
              ),
              const SizedBox(width: AppSpacing.lg),
              Container(width: 1, height: 16, color: AppColors.border),
              const SizedBox(width: AppSpacing.lg),
              Text(
                'Rows per page:',
                style: AppTypography.caption.copyWith(fontSize: 13),
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<int>(
                value: _pageSizes.contains(pageSize) ? pageSize : null,
                isDense: true,
                underline: const SizedBox.shrink(),
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                items: [
                  for (final size in _pageSizes)
                    DropdownMenuItem(value: size, child: Text('$size')),
                ],
                onChanged: (size) {
                  if (size != null) onPageSizeChanged(size);
                },
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: current > 0 ? () => onPageChanged(current - 1) : null,
                icon: const Icon(Icons.chevron_left, size: 20),
              ),
              for (final p in _visiblePages(current, totalPages)) ...[
                if (p == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('…', style: AppTypography.caption),
                  )
                else
                  _PageButton(
                    pageNumber: p + 1,
                    active: p == current,
                    onTap: () => onPageChanged(p),
                  ),
              ],
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: current < totalPages - 1
                    ? () => onPageChanged(current + 1)
                    : null,
                icon: const Icon(Icons.chevron_right, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.pageNumber,
    required this.active,
    required this.onTap,
  });

  final int pageNumber;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          '$pageNumber',
          style: AppTypography.label.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
