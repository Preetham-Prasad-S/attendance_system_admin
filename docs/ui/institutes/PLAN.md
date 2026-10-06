# Institute Switching & Administration — Implementation Plan

> **Status:** Implemented — migrations `0006`–`0008` applied · **Decisions locked:** 2026-10-05
> **Scope:** `supabase/migrations/0006_institutes_registry.sql`, `0007_secondary_institutes.sql`, `0008_account_status.sql`, `supabase/functions/create-institute-admin/`, `lib/features/institutes/`, sidebar switcher, `lib/features/auth/presentation/bloc/session_cubit.dart`

## 1. Goal

Let a `super_admin` see and switch between every institute's data from one app, and manage the registry: create institutes, and create admin accounts scoped to them.

Before this, tenancy existed but was inert: `organization text` on `profiles`/`students`/`staff`/`attendance_records`, scoped by RLS through `current_organization()` (= the caller's own `profiles.organization`). There was no registry to list, `*_select` had no super-admin bypass, and nothing in Dart ever read the caller's `role`.

## 2. Locked decisions

| # | Decision | Choice |
|---|---|---|
| D1 | Tenancy representation | **`institutes` registry table; `organization` stays the slug** on domain tables. No column rewrite, no data migration |
| D2 | Enforcement | **Widen RLS with `can_access_organization()` / `can_write_organization()`** helpers; Dart adds `.eq('organization', slug)` so PostgREST *narrows* what RLS *allows* |
| D3 | Non-home institute rights | **Read + write everywhere** for `super_admin` |
| D4 | Regular `admin` | **Locked single-institute label** — no chevron, no dropdown, no Institutes nav entry |
| D5 | Demo data | **Empty institutes.** Data is created through the app itself |
| D6 | Selection state | **`InstituteContext`** — a `get_it` lazy singleton wrapping a `ValueNotifier` |
| D7 | How the selection reaches queries | **Injected into each datasource.** *Deviation from the original plan*, which threaded a slug parameter through usecase → repository → datasource: 13 methods and ~6 new params classes for a value that is ambient by nature. A datasource throws rather than running unscoped. Blocs keep stale-guards either way |
| D8 | Institute record | **Minimal** — `slug`, `name`, `code`, `is_active` |
| D9 | Management UI | **New Institutes page**, wired to the former inert "System Settings" nav slot (index 9) |
| D10 | Roles assignable | **Admins only.** `role` is hardcoded `'admin'` server-side |
| D11 | Account provisioning | **Edge Function holds `service_role`.** Invited accounts are `status='invited'` (fail-closed), land on `PasswordSetupScreen`, set a password, flip to `'active'` |
| D12 | Institute deletion | **Soft** — `is_active = false` |

### Why D2 is safe

A regular admin's RLS still returns only their own institute's rows. Even if the Dart layer passed a foreign slug they would receive zero rows. The `.eq()` filter is a narrowing tool; **RLS remains the boundary**.

## 3. Schema

**`0006` — registry + widened policies.** `institutes(id, slug unique, name, code, is_active, created_at, updated_at)`, backfilled from the distinct `organization` values already in use (`'CampusPulse'` preserved, `'unassigned'` skipped). Two `security definer` helpers replace the inline org predicates in all six domain policies and `profiles_select`.

**`0007` — two empty institutes** (`apex-institute-of-tech`, `northgate-college`).

**`0008` — account lifecycle.** `account_status` enum, `profiles.status` **defaulting to `'invited'`**, `profiles.invited_by`, plus an immediate backfill of existing rows to `'active'` so the seeded super admin is not locked out. Fail-closed by default: an account that never completes setup cannot enter the app.

`protect_profile_privileges()` is untouched — switching never mutates a profile row.

## 4. Account lifecycle

1. Super admin opens **Institutes → Manage Admins → Invite**.
2. `organization` is **not** user-supplied; it comes from the institute being viewed.
3. App → `functions.invoke('create-institute-admin')`. The function verifies the caller's role **from the database** (not a client claim), validates the institute, creates the user unconfirmed, stamps `invited_by`, and returns a one-time setup link.
4. The link opens the app → `supabase_flutter`'s existing deeplink handler exchanges it → `onAuthStateChange` fires.
5. **`_SessionGate` third branch**: session exists **and** `status == 'invited'` → `PasswordSetupScreen`.
6. `auth.updateUser(password:)` then `UPDATE profiles SET status='active'` (permitted by `profiles_update_own`).
7. Gate re-runs → `AppShell`.

## 5. Phases (all done)

| Phase | Content |
|---|---|
| 1 | `0006` registry, backfill, widened RLS |
| 2 | `0007` empty institutes |
| 3 | `InstituteContext`, institutes data layer + usecases, `SessionCubit`, DI |
| 4 | Thread scoping through 17 query sites; delete `_resolveOrganization()` |
| 5 | Sidebar switcher, real top-bar profile, switch-refresh wiring |
| 6 | `0008` account lifecycle |
| 7 | Edge Function + institute CRUD/invite usecases |
| 8 | `InstitutesPage` with create/edit/deactivate and per-institute admins |
| 9 | `PasswordSetupScreen` + gate branch |
| 10 | Tests |
| 11 | Docs |

## 6. Risks / notes

- **The one security-relevant change** is widening RLS so a super admin's token can read every institute. Intended, but it is the change a reviewer must read deliberately.
- **The Edge Function's authorization is the single most critical line in the feature.** It reads the caller's role from the database. `verify_jwt` is left at its default `true` explicitly in `config.toml`; never deploy with `--no-verify-jwt`.
- **SMTP is the weak link.** Supabase's default mailer is rate-limited to a few messages an hour, so the function returns the setup link for the super admin to pass on instead of emailing it.
- `institutes.slug` and `students.organization` are linked **by convention, not FK**. A `check` constraint or eventual FK is deferred.
- The `handle_new_user()` client-metadata fallback (`coalesce(..., 'unassigned')`) stays open for anyone who can insert into `auth.users`. Unreachable without public signup, and the Edge Function never trusts it — but it is why signup must stay off.
- Blocs reset institute-specific filters on a switch (departments differ per institute) and drop responses whose institute is no longer selected.
- Blocs created inside pages cannot see the root `InstitutesBloc`, so each page owns a `BlocListener` that re-loads on a switch.

## 7. Deviations from the original plan

1. **D7** — scoping by injected context instead of threading a slug parameter through every layer (see above).
2. **`InstituteContext` location** — `lib/features/institutes/domain/services/`, not `lib/core/services/`. Putting it in `core` would have made `core` import a feature entity, inverting the layering.
3. **`InstitutesState`** — one flag-based state instead of the repo's `Initial/Loading/Loaded/Failure` subclass split: this screen runs five independent async operations and a subclass state would discard the institute list whenever an admin query failed.
4. **Edge Functions client** — `supabase_flutter 2.12.4` resolves to `supabase 2.10.6`, which *does* expose `FunctionsClient`; no dependency bump or direct `http` usage was needed.