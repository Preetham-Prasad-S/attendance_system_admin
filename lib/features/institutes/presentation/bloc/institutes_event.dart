import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/usecases/institutes_usecases.dart';
import 'package:flutter/foundation.dart';

/// Events for the institutes registry, the sidebar switcher and the
/// Institutes management page.
@immutable
sealed class InstitutesEvent {
  const InstitutesEvent();
}

/// Loads (or reloads) the registry.
class InstitutesLoadRequested extends InstitutesEvent {
  const InstitutesLoadRequested();
}

/// Switches the institute whose data the app is showing.
class InstituteSelected extends InstitutesEvent {
  final Institute institute;

  const InstituteSelected(this.institute);
}

/// Registers a new institute.
class InstituteCreateRequested extends InstitutesEvent {
  final CreateInstituteParams params;

  const InstituteCreateRequested(this.params);
}

/// Edits an institute's details, or deactivates it.
class InstituteUpdateRequested extends InstitutesEvent {
  final UpdateInstituteRequest request;

  const InstituteUpdateRequested(this.request);
}

/// Loads the admin accounts belonging to an institute.
class InstituteAdminsRequested extends InstitutesEvent {
  final String slug;

  const InstituteAdminsRequested(this.slug);
}

/// Moves an existing account into an institute.
class InstituteAdminAssigned extends InstitutesEvent {
  final AssignAdminParams params;

  const InstituteAdminAssigned(this.params);
}

/// Creates a pending admin account for an institute.
class InstituteAdminInvited extends InstitutesEvent {
  final InviteAdminParams params;

  const InstituteAdminInvited(this.params);
}

/// Dismisses the last feedback banner.
class InstitutesFeedbackCleared extends InstitutesEvent {
  const InstitutesFeedbackCleared();
}