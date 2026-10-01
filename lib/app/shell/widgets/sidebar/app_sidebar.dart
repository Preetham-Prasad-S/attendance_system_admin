import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'sidebar_header.dart';
import 'sidebar_nav_list.dart';
import 'sidebar_university_selector.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

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
          const SidebarUniversitySelector(),
          const SizedBox(height: AppSpacing.xl - 4),
          Expanded(
            child: SingleChildScrollView(
              child: SidebarNavList(
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
