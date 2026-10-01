import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import 'top_bar_actions.dart';
import 'top_bar_profile.dart';
import 'top_bar_search_field.dart';
import 'top_bar_term_selector.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          const TopBarSearchField(),
          const SizedBox(width: AppSpacing.md),
          const TopBarTermSelector(),
          const Spacer(),
          const TopBarActions(),
          const SizedBox(width: AppSpacing.xl),
          const TopBarProfile(),
        ],
      ),
    );
  }
}
