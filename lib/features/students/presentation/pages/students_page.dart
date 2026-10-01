import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

/// Placeholder until the Student Directory screen is implemented
/// (docs/ui/student-directory/PLAN.md — Phases 3–4).
class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Students — coming soon',
        style: AppTypography.sectionTitle,
      ),
    );
  }
}
