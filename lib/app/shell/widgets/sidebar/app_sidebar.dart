import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/material.dart';

import 'sidebar_header.dart';
import 'sidebar_nav_list.dart';
import 'sidebar_university_selector.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.institutes = const [],
    this.selectedInstitute,
    this.isSuperAdmin = false,
    this.onInstituteChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  /// Institutes offered in the switcher dropdown.
  final List<Institute> institutes;

  /// The institute currently being viewed, shown on the switcher card.
  final Institute? selectedInstitute;

  final bool isSuperAdmin;
  final ValueChanged<Institute>? onInstituteChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md + 2,
        vertical: AppSpacing.lg + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SidebarHeader(),
          const SizedBox(height: AppSpacing.lg + 2),
          SidebarUniversitySelector(
            institutes: institutes,
            selected: selectedInstitute,
            isSuperAdmin: isSuperAdmin,
            onChanged: (institute) => onInstituteChanged?.call(institute),
          ),
          const SizedBox(height: AppSpacing.xl - 4),
          Expanded(
            child: SingleChildScrollView(
              child: SidebarNavList(
                selectedIndex: selectedIndex,
                onSelect: onSelect,
                isSuperAdmin: isSuperAdmin,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
