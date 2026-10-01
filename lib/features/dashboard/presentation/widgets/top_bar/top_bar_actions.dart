import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TopBarActions extends StatelessWidget {
  const TopBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 21),
              color: AppColors.textSecondary,
              style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune, size: 20),
          color: AppColors.textSecondary,
          style: IconButton.styleFrom(padding: const EdgeInsets.all(8)),
        ),
        const SizedBox(width: 4),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Quick Actions'),
        ),
      ],
    );
  }
}
