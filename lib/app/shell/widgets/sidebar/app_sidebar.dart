import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'sidebar_header.dart';
import 'sidebar_nav_list.dart';
import 'sidebar_university_selector.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

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
          const Expanded(child: SingleChildScrollView(child: SidebarNavList())),
        ],
      ),
    );
  }
}
