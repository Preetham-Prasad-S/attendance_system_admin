import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/auth_event.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Signed-in user's identity, read from [SessionCubit] rather than hardcoded.
class TopBarProfile extends StatelessWidget {
  const TopBarProfile({super.key});

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static String _roleLabel(String? role) => switch (role) {
    'super_admin' => 'Super Admin',
    'admin' => 'Institute Admin',
    _ => 'Administrator',
  };

  @override
  Widget build(BuildContext context) {
    final user = context.select<SessionCubit, UserEntity?>(
      (cubit) => cubit.state is SessionActive
          ? (cubit.state as SessionActive).user
          : (cubit.state is SessionInvited
                ? (cubit.state as SessionInvited).user
                : null),
    );

    if (user == null) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'sign_out') {
          context.read<AuthBloc>().add(LogoutRequested());
          context.read<SessionCubit>().reset();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'sign_out',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout_rounded, size: 18),
              const SizedBox(width: AppSpacing.sm),
              const Text('Sign out'),
            ],
          ),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.primary,
            child: Text(
              _initials(user.name),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _roleLabel(user.role),
                style: AppTypography.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}