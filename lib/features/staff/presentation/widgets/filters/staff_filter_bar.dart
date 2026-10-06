import 'dart:async';

import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/staff/domain/entities/staff_entities.dart';
import 'package:flutter/material.dart';

/// Search (300 ms debounce), department / designation / status dropdowns, a
/// dashed "More Filters" placeholder, and the Show Available Only switch.
class StaffFilterBar extends StatefulWidget {
  const StaffFilterBar({
    super.key,
    required this.filters,
    required this.departments,
    required this.designations,
    required this.onSearch,
    required this.onDepartment,
    required this.onDesignation,
    required this.onStatus,
    required this.onAvailableOnly,
    required this.onMoreFilters,
    required this.onReset,
  });

  final StaffFilters filters;

  /// Distinct values, injected rather than derived here so the widget stays
  /// free of mock-data knowledge.
  final List<String> departments;
  final List<String> designations;

  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onDepartment;
  final ValueChanged<String?> onDesignation;
  final ValueChanged<FacultyStatus?> onStatus;
  final ValueChanged<bool> onAvailableOnly;

  /// No additional filters exist yet — wired to a snackbar by the page.
  final VoidCallback onMoreFilters;

  final VoidCallback onReset;

  @override
  State<StaffFilterBar> createState() => _StaffFilterBarState();
}

class _StaffFilterBarState extends State<StaffFilterBar> {
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  Timer? _debounce;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.searchQuery);
  }

  @override
  void didUpdateWidget(StaffFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the field in sync when the filter is reset from elsewhere.
    if (widget.filters.searchQuery != _searchController.text) {
      _searchController.text = widget.filters.searchQuery;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, () {
      if (mounted) widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search faculty by name, ID or department',
                    hintStyle: AppTypography.label.copyWith(
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: const BorderSide(
                        color: AppColors.primaryLight,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              _SelectBox(
                value: filters.department,
                placeholder: 'All Departments',
                options: {
                  for (final dept in widget.departments) dept: 'Dept: $dept',
                },
                onChanged: widget.onDepartment,
              ),
              _SelectBox(
                value: filters.designation,
                placeholder: 'All Designations',
                options: {
                  for (final d in widget.designations) d: 'Designation: $d',
                },
                onChanged: widget.onDesignation,
              ),
              _SelectBox<FacultyStatus>(
                value: filters.status,
                placeholder: 'All Statuses',
                options: {
                  for (final status in FacultyStatus.values)
                    status: 'Status: ${status.label}',
                },
                onChanged: widget.onStatus,
              ),
              _MoreFiltersButton(onTap: widget.onMoreFilters),
              if (filters.isActive)
                _ResetButton(
                  onTap: () {
                    _debounce?.cancel();
                    widget.onReset();
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Show Available Only:',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Switch(
                value: filters.availableOnly,
                onChanged: widget.onAvailableOnly,
                activeThumbColor: AppColors.surface,
                activeTrackColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bordered 42px dropdown matching the students directory's filter styling.
class _SelectBox<T> extends StatelessWidget {
  const _SelectBox({
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onChanged,
  });

  final T? value;
  final String placeholder;

  /// Entries render as dropdown items; the current [value] selects one.
  final Map<T, String> options;

  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: value == null ? AppColors.border : AppColors.primaryLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text(
                placeholder,
                style: AppTypography.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            for (final entry in options.entries)
              DropdownMenuItem<T>(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: onChanged,
          style: AppTypography.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Dashed-outline placeholder: the design shows more filters, but none of
/// them have a data source yet.
class _MoreFiltersButton extends StatelessWidget {
  const _MoreFiltersButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.textMuted,
          radius: AppRadius.md,
        ),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'More Filters',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flutter has no dashed border primitive; this paints one so the placeholder
/// reads as "not yet available" without disabling the control.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dashWidth = 5;
  static const double _gapWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashWidth),
          paint,
        );
        distance += _dashWidth + _gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.danger),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close, size: 16, color: AppColors.dangerDark),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Reset Filters',
              style: AppTypography.label.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.dangerDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
