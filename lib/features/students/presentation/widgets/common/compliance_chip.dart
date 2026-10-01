import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/students_entities.dart';

/// Tier-derived colors shared by the directory table and detail panel.
abstract final class TierPalette {
  /// Fill color for the attendance progress bar.
  static Color progress(ComplianceTier tier) => switch (tier) {
    ComplianceTier.excellent ||
    ComplianceTier.good ||
    ComplianceTier.compliant =>
      AppColors.success,
    ComplianceTier.borderline => AppColors.warning,
    ComplianceTier.critical => AppColors.danger,
    ComplianceTier.noData => AppColors.textMuted,
  };

  /// Foreground color for percentages and tier labels.
  static Color foreground(ComplianceTier tier) => switch (tier) {
    ComplianceTier.excellent ||
    ComplianceTier.good ||
    ComplianceTier.compliant =>
      AppColors.successDark,
    ComplianceTier.borderline => AppColors.warningDark,
    ComplianceTier.critical => AppColors.dangerDark,
    ComplianceTier.noData => AppColors.textMuted,
  };

  static Color chipBackground(ComplianceTier tier) => switch (tier) {
    ComplianceTier.excellent ||
    ComplianceTier.good ||
    ComplianceTier.compliant =>
      AppColors.successSurface,
    ComplianceTier.borderline => AppColors.warningSurface,
    ComplianceTier.critical => AppColors.dangerSurface,
    ComplianceTier.noData => AppColors.surfaceMuted,
  };
}

/// Status chip: colored dot + [ComplianceTier.chipLabel] (Regular / Defaulter /
/// Critical / —).
class ComplianceChip extends StatelessWidget {
  const ComplianceChip({super.key, required this.tier, this.showDot = true});

  final ComplianceTier tier;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final fg = TierPalette.foreground(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TierPalette.chipBackground(tier),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            tier.chipLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
