/// Lifecycle of a profile account, mirroring `public.account_status`
/// (migration `0008_account_status.sql`).
enum AccountStatus {
  /// Invited by a super admin but has not set a password yet. Invited
  /// accounts cannot enter the app.
  invited,

  /// Password has been set; the account may enter the app.
  active;

  /// Parses the DB value, defaulting to [invited] so that an unknown or
  /// missing value can never grant access.
  static AccountStatus fromString(String? value) =>
      value?.toLowerCase() == 'active' ? AccountStatus.active : AccountStatus.invited;

  bool get isActive => this == AccountStatus.active;
}