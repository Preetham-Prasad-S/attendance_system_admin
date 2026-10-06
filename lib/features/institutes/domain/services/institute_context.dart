import 'package:attendance_system_admin/core/entities/user_entity.dart';
import 'package:attendance_system_admin/features/institutes/domain/entities/institute_entity.dart';
import 'package:flutter/foundation.dart';

/// Holds the signed-in user and which institute is currently being viewed.
///
/// Lives in the institutes feature rather than `core` so that `core` never
/// has to import a feature entity. Registered as a lazy singleton in
/// `injection_container.dart` and injected into the dashboard/students blocs
/// and datasources — every read is an explicit read, never an implicit one.
class InstituteContext {
  UserEntity? _currentUser;

  /// The institute whose data the app is currently showing.
  final ValueNotifier<Institute?> selectedInstitute =
      ValueNotifier<Institute?>(null);

  InstituteContext({UserEntity? currentUser}) : _currentUser = currentUser;

  UserEntity? get currentUser => _currentUser;

  /// True for `role = 'super_admin'`. Only these accounts see the switcher
  /// dropdown and the Institutes page.
  bool get isSuperAdmin => _currentUser?.isSuperAdmin ?? false;

  /// The institute the user belongs to (`profiles.organization`).
  String? get homeSlug => _currentUser?.organization;

  Institute? get selected => selectedInstitute.value;

  /// Slug to scope every institute-scoped query to. Null before the context
  /// has been initialised — callers must treat that as "not ready".
  String? get selectedSlug => selectedInstitute.value?.slug;

  void setCurrentUser(UserEntity? user) => _currentUser = user;

  void selectInstitute(Institute? institute) =>
      selectedInstitute.value = institute;

  /// Restores the default selection: the user's own institute.
  void selectHomeInstitute(List<Institute> institutes) {
    final homeSlug = this.homeSlug;
    if (homeSlug == null) return;
    for (final institute in institutes) {
      if (institute.slug == homeSlug) {
        selectedInstitute.value = institute;
        return;
      }
    }
  }

  void clear() {
    _currentUser = null;
    selectedInstitute.value = null;
  }

  void dispose() => selectedInstitute.dispose();
}