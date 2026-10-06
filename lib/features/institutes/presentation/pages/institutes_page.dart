import 'package:attendance_system_admin/core/theme/app_colors.dart';
import 'package:attendance_system_admin/core/theme/app_spacing.dart';
import 'package:attendance_system_admin/core/theme/app_typography.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_cubit.dart';
import 'package:attendance_system_admin/features/auth/presentation/bloc/session_state.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_bloc.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_event.dart';
import 'package:attendance_system_admin/features/institutes/presentation/bloc/institutes_state.dart';
import 'package:attendance_system_admin/features/institutes/presentation/widgets/institute_admins_dialog.dart';
import 'package:attendance_system_admin/features/institutes/presentation/widgets/institute_form_dialog.dart';
import 'package:attendance_system_admin/features/institutes/presentation/widgets/institutes_table_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Super-admin screen for registering institutes, switching between them, and
/// managing each institute's admin accounts.
///
/// Reachable only from the sidebar's Institutes entry, which is itself hidden
/// from regular admins; the guard below is a second line of defence so the
/// page is not usable if it is ever rendered some other way.
class InstitutesPage extends StatelessWidget {
  const InstitutesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = context.select<SessionCubit, bool>(
      (cubit) =>
          cubit.state is SessionActive &&
          (cubit.state as SessionActive).user.isSuperAdmin,
    );

    if (!isSuperAdmin) {
      return const Center(
        child: Text(
          'Only super admins can manage institutes.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return BlocConsumer<InstitutesBloc, InstitutesState>(
      listenWhen: (previous, current) =>
          current.feedbackMessage != null &&
          previous.feedbackMessage != current.feedbackMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(state.feedbackMessage!),
            backgroundColor: state.feedbackIsError
                ? AppColors.danger
                : AppColors.successDark,
          ),
        );
        context.read<InstitutesBloc>().add(const InstitutesFeedbackCleared());
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<InstitutesBloc>().add(
              const InstitutesLoadRequested(),
            );
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _Header(
                state: state,
                onAddInstitute: () => _openForm(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              InstitutesTableCard(
                institutes: state.institutes,
                selectedSlug: state.selectedSlug,
                onSelect: (institute) {
                  context.read<InstitutesBloc>().add(
                    InstituteSelected(institute),
                  );
                },
                onEdit: (institute) => _openForm(context, institute: institute),
                onToggleActive: (institute) => _toggleActive(context, institute),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SelectedInstituteFooter(state: state, onManageAdmins: () {}),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    Institute? institute,
  }) async {
    final bloc = context.read<InstitutesBloc>();
    final result = await showDialog<InstituteFormResult>(
      context: context,
      builder: (_) => InstituteFormDialog(institute: institute),
    );
    if (result == null) return;

    if (institute == null) {
      bloc.add(InstituteCreateRequested(result.createParams));
    } else {
      bloc.add(
        InstituteUpdateRequested(
          UpdateInstituteRequest(
            slug: institute.slug,
            changes: result.updateParams,
          ),
        ),
      );
    }
  }

  void _toggleActive(BuildContext context, Institute institute) {
    context.read<InstitutesBloc>().add(
      InstituteUpdateRequested(
        UpdateInstituteRequest(
          slug: institute.slug,
          changes: UpdateInstituteParams(isActive: !institute.isActive),
        ),
      ),
    );
  }
}

Future<void> _openAdminsDialog(BuildContext context, Institute institute) async {
  final bloc = context.read<InstitutesBloc>();
  bloc.add(InstituteAdminsRequested(institute.slug));

  final inviteParams = await showDialog<InviteAdminParams>(
    context: context,
    builder: (dialogContext) => BlocBuilder<InstitutesBloc, InstitutesState>(
      builder: (context, state) => InstituteAdminsDialog(
        institute: institute,
        admins: state.adminsForSlug == institute.slug ? state.admins : const [],
        isLoading: state.isLoadingAdmins,
        isSubmitting: state.isSubmitting,
        setupLink: state.inviteSetupLink,
      ),
    ),
  );

  if (inviteParams != null) {
    bloc.add(InstituteAdminInvited(inviteParams));
    // Re-open so the pending admin and the new setup link are visible.
    if (context.mounted) await _openAdminsDialog(context, institute);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.onAddInstitute});

  final InstitutesState state;
  final VoidCallback onAddInstitute;

  @override
  Widget build(BuildContext context) {
    final activeCount = state.institutes
        .where((institute) => institute.isActive)
        .length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Administration  /  Institutes',
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Institutes', style: AppTypography.pageTitle),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$activeCount active of ${state.institutes.length} registered. '
                'Switch the institute on screen from the sidebar, or manage the '
                'admins of each institute here.',
                style: AppTypography.pageSubtitle,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        FilledButton.icon(
          onPressed: onAddInstitute,
          icon: const Icon(Icons.add_business_outlined, size: 17),
          label: const Text('+ Add Institute'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
            textStyle: AppTypography.button,
          ),
        ),
      ],
    );
  }
}

class _SelectedInstituteFooter extends StatelessWidget {
  const _SelectedInstituteFooter({required this.state, required this.onManageAdmins});

  final InstitutesState state;
  final VoidCallback onManageAdmins;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedInstitute;

    return Row(
      children: [
        Expanded(
          child: Text(
            selected == null
                ? 'No institute selected.'
                : 'Viewing ${selected.name} (${selected.slug}).',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: selected == null
              ? null
              : () => _openAdminsDialog(context, selected),
          icon: const Icon(Icons.group_add_outlined, size: 17),
          label: const Text('Manage Admins'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
          ),
        ),
      ],
    );
  }
}