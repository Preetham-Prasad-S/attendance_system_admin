import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class LiveIoTStreamCard extends StatelessWidget {
  const LiveIoTStreamCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_tethering,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Live IoT Stream',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.sectionTitle.copyWith(fontSize: 15),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.successDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'INGESTING',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.successDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _StreamEntry(
            name: 'Aarav Patel',
            status: 'Present',
            statusColor: AppColors.successDark,
            statusBackground: AppColors.successSurface,
            subtitle: 'CS-302 \u2022 Main Gate Camera #02',
            meta: '08:42:15 AM \u2022 99.1% Confidence',
            metaIcon: Icons.verified_outlined,
            metaColor: AppColors.textMuted,
            tint: AppColors.successSurface,
            tintIcon: AppColors.successDark,
          ),
          _divider(),
          _StreamEntry(
            name: 'Prof. Sarah Jenkins',
            status: 'Present',
            statusColor: AppColors.successDark,
            statusBackground: AppColors.successSurface,
            subtitle: 'Physics Faculty \u2022 Faculty Block A',
            meta: '08:41:50 AM \u2022 Biometric Match',
            metaIcon: Icons.fingerprint,
            metaColor: AppColors.textMuted,
            tint: AppColors.successSurface,
            tintIcon: AppColors.successDark,
          ),
          _divider(),
          _StreamEntry(
            name: 'Rohan Sharma',
            status: 'Late',
            statusColor: AppColors.warningDark,
            statusBackground: AppColors.warningSurface,
            subtitle: 'ME-104 \u2022 Library Kiosk Gate',
            meta: '08:40:02 AM \u2022 +10m late',
            metaIcon: Icons.schedule,
            metaColor: AppColors.warningDark,
            tint: AppColors.warningSurface,
            tintIcon: AppColors.warningDark,
          ),
          _divider(),
          _StreamEntry(
            name: 'Priya Nair',
            status: 'Present',
            statusColor: AppColors.successDark,
            statusBackground: AppColors.successSurface,
            subtitle: 'EC-201 \u2022 Lab Complex QR Terminal',
            meta: '08:38:22 AM \u2022 App Authenticated',
            metaIcon: Icons.smartphone,
            metaColor: AppColors.textMuted,
            tint: AppColors.successSurface,
            tintIcon: AppColors.successDark,
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: double.infinity,
              child: Text(
                'Open Full Real-Time Gateway Log (26 Devices) \u2192',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.chartLine,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Divider(height: 1, thickness: 1, color: AppColors.border),
  );
}

class _StreamEntry extends StatelessWidget {
  const _StreamEntry({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.subtitle,
    required this.meta,
    required this.metaIcon,
    required this.metaColor,
    required this.tint,
    required this.tintIcon,
  });

  final String name;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final String subtitle;
  final String meta;
  final IconData metaIcon;
  final Color metaColor;
  final Color tint;
  final Color tintIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: Icon(Icons.person_outline, size: 17, color: tintIcon),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      status,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(metaIcon, size: 11, color: metaColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      meta,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10.5,
                        color: metaColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
