import 'package:attendance_system_admin/core/entities/account_status.dart';
import 'package:flutter/foundation.dart';

/// The tenant key derived from an institute name: lowercase, hyphenated,
/// trimmed. Shared so the create dialog can preview the slug the datasource
/// will store, and so the rule lives in exactly one place.
String slugifyInstituteName(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+'), '')
    .replaceAll(RegExp(r'-+$'), '');

/// An institute in the registry. [slug] is the tenant key stored in the
/// `organization` column of `students`, `staff` and `attendance_records`
/// (linked by convention — see docs/backend/SCHEMA.md).
@immutable
class Institute {
  final String id;
  final String slug;
  final String name;

  /// Optional short label. Not fabricated by the backfill, so usually null.
  final String? code;

  /// Inactive institutes stay in the registry so their historical rows keep
  /// resolving, but are hidden from the sidebar switcher.
  final bool isActive;

  const Institute({
    required this.id,
    required this.slug,
    required this.name,
    this.code,
    this.isActive = true,
  });

  factory Institute.fromMap(Map<String, dynamic> map) => Institute(
    id: map['id'] as String,
    slug: map['slug'] as String,
    name: map['name'] as String,
    code: map['code'] as String?,
    isActive: map['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'slug': slug,
    'name': name,
    'code': code,
    'is_active': isActive,
  };

  Institute copyWith({String? name, String? code, bool? isActive}) => Institute(
    id: id,
    slug: slug,
    name: name ?? this.name,
    code: code ?? this.code,
    isActive: isActive ?? this.isActive,
  );

  @override
  bool operator ==(Object other) =>
      other is Institute &&
      other.id == id &&
      other.slug == slug &&
      other.name == name &&
      other.code == code &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, slug, name, code, isActive);

  @override
  String toString() => 'Institute($slug, $name)';
}

/// An admin account that belongs to an institute.
@immutable
class InstituteAdmin {
  final String id;
  final String email;
  final String name;

  /// [AccountStatus.invited] until the invitee completes password setup.
  final AccountStatus status;

  const InstituteAdmin({
    required this.id,
    required this.email,
    required this.name,
    required this.status,
  });

  factory InstituteAdmin.fromMap(Map<String, dynamic> map) => InstituteAdmin(
    id: map['id'] as String,
    email: map['email'] as String,
    name: map['name'] as String,
    status: AccountStatus.fromString(map['status'] as String?),
  );

  bool get isPending => status == AccountStatus.invited;

  @override
  bool operator ==(Object other) =>
      other is InstituteAdmin &&
      other.id == id &&
      other.email == email &&
      other.name == name &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, email, name, status);
}

/// Fields for creating an institute (migration 0006: minimal record).
@immutable
class CreateInstituteParams {
  final String name;
  final String? code;

  const CreateInstituteParams({required this.name, this.code});
}

/// Fields for editing an institute. Null leaves a column untouched.
@immutable
class UpdateInstituteParams {
  final String? name;
  final String? code;
  final bool? isActive;

  const UpdateInstituteParams({this.name, this.code, this.isActive});
}

/// Fields for inviting an admin into an institute. The institute is never
/// user-supplied — it comes from the currently selected institute.
@immutable
class InviteAdminParams {
  final String name;
  final String email;
  final String instituteSlug;

  const InviteAdminParams({
    required this.name,
    required this.email,
    required this.instituteSlug,
  });
}

/// Outcome of an invitation: the created profile plus a one-time setup link.
/// The link is returned so the super admin can pass it on manually when email
/// delivery is rate-limited or unavailable (see docs/backend/DECISIONS.md).
@immutable
class InviteAdminResult {
  final String profileId;
  final String? setupLink;

  const InviteAdminResult({required this.profileId, this.setupLink});
}