import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/foundation.dart';

/// State for the institutes registry and management page.
///
/// A single flag-based state rather than the Initial/Loading/Loaded/Failure
/// subclass split used elsewhere: this screen runs several independent async
/// operations (registry, admins, create, assign, invite) and a subclass state
/// would throw the institute list away every time an admin query failed.
@immutable
class InstitutesState {
  final List<Institute> institutes;
  final String? selectedSlug;
  final List<InstituteAdmin> admins;

  /// Which institute [admins] belongs to.
  final String? adminsForSlug;

  final bool isLoading;
  final bool isLoadingAdmins;
  final bool isSubmitting;

  /// Banner text for the last completed action.
  final String? feedbackMessage;
  final bool feedbackIsError;

  /// Set after a successful invite so the page can offer the setup link.
  final String? inviteSetupLink;

  const InstitutesState({
    this.institutes = const [],
    this.selectedSlug,
    this.admins = const [],
    this.adminsForSlug,
    this.isLoading = false,
    this.isLoadingAdmins = false,
    this.isSubmitting = false,
    this.feedbackMessage,
    this.feedbackIsError = false,
    this.inviteSetupLink,
  });

  /// Institutes offered in the switcher dropdown. Inactive ones are kept in
  /// [institutes] so a user whose institute was deactivated still resolves it,
  /// but they are not offered as a choice.
  List<Institute> get switchableInstitutes => institutes
      .where((institute) => institute.isActive)
      .toList(growable: false);

  Institute? get selectedInstitute {
    final slug = selectedSlug;
    if (slug == null) return null;
    for (final institute in institutes) {
      if (institute.slug == slug) return institute;
    }
    return null;
  }

  InstitutesState copyWith({
    List<Institute>? institutes,
    String? selectedSlug,
    bool clearSelectedSlug = false,
    List<InstituteAdmin>? admins,
    String? adminsForSlug,
    bool clearAdmins = false,
    bool? isLoading,
    bool? isLoadingAdmins,
    bool? isSubmitting,
    String? feedbackMessage,
    bool? feedbackIsError,
    String? inviteSetupLink,
    bool clearInviteSetupLink = false,
    bool clearFeedback = false,
  }) {
    return InstitutesState(
      institutes: institutes ?? this.institutes,
      selectedSlug: clearSelectedSlug ? null : (selectedSlug ?? this.selectedSlug),
      admins: clearAdmins ? const [] : (admins ?? this.admins),
      adminsForSlug: clearAdmins ? null : (adminsForSlug ?? this.adminsForSlug),
      isLoading: isLoading ?? this.isLoading,
      isLoadingAdmins: isLoadingAdmins ?? this.isLoadingAdmins,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackIsError: clearFeedback ? false : (feedbackIsError ?? this.feedbackIsError),
      inviteSetupLink: clearInviteSetupLink
          ? null
          : (inviteSetupLink ?? this.inviteSetupLink),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is InstitutesState &&
      other.institutes == institutes &&
      other.selectedSlug == selectedSlug &&
      other.admins == admins &&
      other.adminsForSlug == adminsForSlug &&
      other.isLoading == isLoading &&
      other.isLoadingAdmins == isLoadingAdmins &&
      other.isSubmitting == isSubmitting &&
      other.feedbackMessage == feedbackMessage &&
      other.feedbackIsError == feedbackIsError &&
      other.inviteSetupLink == inviteSetupLink;

  @override
  int get hashCode => Object.hash(
    institutes,
    selectedSlug,
    admins,
    adminsForSlug,
    isLoading,
    isLoadingAdmins,
    isSubmitting,
    feedbackMessage,
    feedbackIsError,
    inviteSetupLink,
  );
}