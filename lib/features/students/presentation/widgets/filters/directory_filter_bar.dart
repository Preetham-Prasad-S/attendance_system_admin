import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/students_entities.dart';

/// Search box (300 ms debounce), department/status dropdowns, disabled
/// placeholder dropdowns, and the quick-filter chips.
class DirectoryFilterBar extends StatefulWidget {
  const DirectoryFilterBar({
    super.key,
    required this.filters,
    required this.kpis,
    required this.onSearch,
    required this.onDepartment,
    required this.onStatus,
    required this.onQuickFilter,
  });

  final DirectoryFilters filters;
  final DirectoryKpis kpis;

  /// Fired after the 300 ms search debounce elapses.
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onDepartment;
  final ValueChanged<String?> onStatus;
  final ValueChanged<bool> onQuickFilter;

  @override
  State<DirectoryFilterBar> createState() => _DirectoryFilterBarState();
}

class _DirectoryFilterBarState extends State<DirectoryFilterBar> {
  Timer? _debounce;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.searchQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    final kpis = widget.kpis;

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
                width: 340,
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Filter by Student Name, Roll No., Email',
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
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'Department: All (${kpis.availableDepartments.length})',
                    ),
                  ),
                  for (final dept in kpis.availableDepartments)
                    DropdownMenuItem<String?>(
                      value: dept,
                      child: Text('Department: $dept'),
                    ),
                ],
                onChanged: widget.onDepartment,
              ),
              _SelectBox(
                value: filters.status,
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Status: All Records'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'active',
                    child: Text('Status: Active'),
                  ),
                  DropdownMenuItem<String?>(
                    value: 'inactive',
                    child: Text('Status: Inactive'),
                  ),
                ],
                onChanged: widget.onStatus,
              ),
              const _DisabledBox(label: 'Class / Sem: All'),
              const _DisabledBox(label: 'Batch: 2021–2025'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Quick Filters:',
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              _QuickChip(
                label: 'All Students',
                active: !filters.criticalOnly,
                onTap: () => widget.onQuickFilter(false),
              ),
              _QuickChip(
                label: 'Critical Defaulters (${kpis.criticalCount})',
                active: filters.criticalOnly,
                danger: true,
                onTap: () => widget.onQuickFilter(true),
              ),
              const _QuickChip(label: 'Hostellers', enabled: false),
              const _QuickChip(label: 'Day Scholars', enabled: false),
              const _QuickChip(label: 'Pending Medical Leave', enabled: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  const _SelectBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isDense: true,
          items: items,
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

class _DisabledBox extends StatelessWidget {
  const _DisabledBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    this.active = false,
    this.danger = false,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool active;
  final bool danger;

  /// False renders a disabled placeholder chip (no data behind it yet).
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color borderColor;

    if (!enabled) {
      background = AppColors.surfaceMuted;
      foreground = AppColors.textMuted;
      borderColor = AppColors.surfaceMuted;
    } else if (active) {
      background = AppColors.primary;
      foreground = AppColors.surface;
      borderColor = AppColors.primary;
    } else if (danger) {
      background = AppColors.surface;
      foreground = AppColors.dangerDark;
      borderColor = AppColors.danger;
    } else {
      background = AppColors.surface;
      foreground = AppColors.textSecondary;
      borderColor = AppColors.border;
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
