import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class KpiStatCard extends StatelessWidget {
  const KpiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.labelColor = AppColors.textMuted,
    this.valueColor = AppColors.textPrimary,
    this.icon,
    this.iconColor = AppColors.textMuted,
    this.badgeText,
    this.badgeForeground,
    this.badgeBackground,
    this.progressValue,
    this.footer,
    this.footerColor = AppColors.textMuted,
    this.footerIcon,
    this.accentColor,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final IconData? icon;
  final Color iconColor;
  final String? badgeText;
  final Color? badgeForeground;
  final Color? badgeBackground;
  final double? progressValue;
  final String? footer;
  final Color footerColor;
  final IconData? footerIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildCardContent(),
          ),
          if (accentColor != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(height: 3, color: accentColor),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.statLabel.copyWith(color: labelColor),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 1,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: badgeBackground ?? AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  badgeText!,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeForeground ?? AppColors.successDark,
                  ),
                ),
              ),
            ],
            if (icon != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(icon, size: 18, color: iconColor),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg + 2),
        Text(value, style: AppTypography.statValue.copyWith(color: valueColor)),
        if (progressValue != null) ...[
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              color: AppColors.success,
              backgroundColor: AppColors.successSurface,
            ),
          ),
        ],
        if (footer != null) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (footerIcon != null) ...[
                Icon(footerIcon, size: 13, color: footerColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Expanded(
                child: Text(
                  footer!,
                  style: AppTypography.caption.copyWith(color: footerColor),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
