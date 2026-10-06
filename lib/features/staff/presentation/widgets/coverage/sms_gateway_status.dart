import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_radius.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Edge-device health tile for the SMS gateway that carries substitute
/// notifications. Cyan per the design system's device-telemetry role.
class SmsGatewayStatus extends StatelessWidget {
  const SmsGatewayStatus({
    super.key,
    this.isOnline = true,
    this.latencyMs = 120,
    this.gatewayName = 'Campus SMS Gateway',
  });

  final bool isOnline;
  final int latencyMs;
  final String gatewayName;

  @override
  Widget build(BuildContext context) {
    final (Color dot, Color fg, Color bg) = isOnline
        ? (AppColors.success, AppColors.successDark, AppColors.successSurface)
        : (AppColors.danger, AppColors.dangerDark, AppColors.dangerSurface);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isOnline ? AppColors.success : AppColors.danger,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.sms_outlined,
            size: 17,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              gatewayName,
              style: AppTypography.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            isOnline ? 'Active (Latency: ${latencyMs}ms)' : 'Disconnected',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
