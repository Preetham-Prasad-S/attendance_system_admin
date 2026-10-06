# Backend Implementation Plan

Step-by-step plan for **Phase: Schema + Auth**. This is the source of truth for progress — update the status of each step as it completes.

- Target backend: **Supabase** (project `hlgqszvnfrbyuhaxqlof`)
- State management / DI: **flutter_bloc + get_it + fpdart**
- Schema management: **Supabase CLI migrations** (`supabase/migrations/*.sql`)
- Account policy: **seeded super admin only** — no public signup
- Database is **empty/disposable** — safe to drop and recreate

See [SCHEMA.md](SCHEMA.md) for table designs and [DECISIONS.md](DECISIONS.md) for why these choices were made.

---

## Step 1 — Tooling: install & link Supabase CLI

**Status:** ✅ Done (2026-10-01)

1. ~~Install the CLI~~ — installed via `npm install -g supabase` (v2.118.0; no winget/scoop/choco on this machine)
2. ~~`supabase init`~~ — created `supabase/config.toml` + gitignored `supabase/.temp/`
3. ~~`supabase login`~~ — run manually by the project owner (non-TTY shell can't do the browser OAuth flow)
4. ~~`supabase link --project-ref hlgqszvnfrbyuhaxqlof`~~ — linked (project was paused; restored from dashboard first)
5. **DB inspection result:** legacy `"User"` table exists and is **empty**; `profiles`/`students`/`staff`/`attendance_records` do not exist; remote migration list is empty. `db dump` needs Docker (not installed), so legacy cleanup is handled defensively inside migration 0001 (`drop table if exists "User"` + drop old trigger/function).

**Done when:** ✅ `supabase migration list` runs and shows the linked remote project.

## Step 2 — Migration `0001_core_schema.sql`

**Status:** ✅ Done (2026-10-01)

Creates the authentication foundation:

1. ✅ Enum `public.app_role` → `('super_admin', 'admin')`
2. ✅ Table `public.profiles` (1:1 with `auth.users`) — see [SCHEMA.md](SCHEMA.md#profiles)
3. ✅ Trigger `handle_new_user()` on `auth.users after insert` → copies `raw_user_meta_data` (name, department, phone_no, organization) + email into `profiles`
4. ✅ Helper functions `public.current_organization()` and `public.current_app_role()` (`security definer` — avoids RLS recursion; `current_role` is a reserved SQL keyword, hence the `_app` name)
5. ✅ `updated_at` trigger + `profiles_protect_privileges` trigger (blocks non-super-admins from changing role/organization/id)
6. ✅ RLS enabled on `profiles`:
   - `select`: authenticated users, self or same organization
   - `update`: own row (guarded), or any row if `super_admin`
   - **no** anon policies, **no** client-side insert (users are created via dashboard/admin API only)
7. ✅ Legacy cleanup: dropped old `"User"` table + any `handle_new_user` trigger on `auth.users`

**Applied:** `supabase db push` → remote migration list matches local (`20260930190644`).
**Verified:** `"User"` → 404 (gone); `profiles` → exists, anon gets `[]` (RLS filtering).

## Step 3 — Migration `0002_core_domain.sql`

**Status:** ✅ Done (2026-10-01)

Core domain tables (org-scoped, RLS on all):

1. ✅ `public.students` — see [SCHEMA.md](SCHEMA.md#students)
2. ✅ `public.staff` — see [SCHEMA.md](SCHEMA.md#staff)
3. ✅ `public.attendance_records` — see [SCHEMA.md](SCHEMA.md#attendance_records)

Note: `create policy … for insert, update, delete` is invalid Postgres (one command per policy) — implemented as `for all` instead.

Explicitly deferred to later phases (documented in the migration header): timetable, subjects/class sections, leave requests, IoT devices, alerts/notifications.

**Done when:** ✅ migration applies; all three tables have RLS enabled. Verified — anon queries return `[]` for all four tables.

## Step 4 — Seed super admin

**Status:** ✅ Done (2026-10-01)

1. ✅ Auth user created in the Supabase dashboard: `preetham2005105@gmail.com` (auto-confirmed)
2. ✅ Migration `0003_seed_super_admin.sql` — promotes the user to `role = 'super_admin'`, sets `organization = 'CampusPulse'`, replaces email-style name with the local part. Includes a guard that raises if the profile row is missing.
3. ✅ No passwords in the repo — migration only touches the already-created row.

**Done when:** ✅ migration applied; guard passed (profile row found and updated).

## Step 5 — Flutter config fixes

**Status:** ✅ Done (2026-10-01)

1. ✅ `lib/main.dart`: `dotenv.load(fileName: "assets/.env")` — flutter_dotenv 6.0.1 calls `rootBundle.loadString(fileName)` with the exact path; `".env"` would throw `FileNotFoundError`
2. ✅ Env key is already `SUPABASE_API_ANON_KEY` in `assets/.env` (typo fixed outside this plan) — `main.dart` reads the correct name
3. ✅ `Supabase.initialize(url:, anonKey:)` re-enabled in `main()` before `runApp`
4. ✅ Verified `KEY = value` spacing in `.env` is handled (flutter_dotenv's parser trims keys/values)

**Done when:** ✅ `flutter analyze` — no issues.

## Step 6 — Recover auth code from git HEAD

**Status:** ✅ Done (2026-10-01)

Restored from commit `843a7fe` via `git checkout HEAD -- <paths>`:

- ✅ `lib/core/failure.dart`, `lib/core/usecase.dart`, `lib/core/models/user_model.dart`, `lib/core/entities/user_entity.dart`
- ✅ `lib/features/auth/**` — 29 files (data, domain, bloc, presentation)
- ✅ `test/features/auth/**` — 5 test files

**Not restored** (superseded): `core/screens/base_screen.dart`, `core/app_colors.dart`, `lib/dependency.dart`.

**Done when:** ✅ files are back in the working tree (compile errors expected until Step 7).

## Step 7 — Adapt recovered auth code

**Status:** ✅ Done (2026-10-01)

1. ✅ Fixed imports: `core/app_colors.dart` → `core/theme/app_colors.dart`; remapped old constants → new theme (`blueColor→primary`, `whiteColor→surface`, `lightScaffoldColor→background`)
2. ✅ `BaseScreen` replaced: session gate now lives in `lib/app/app.dart` (`_SessionGate` — `onAuthStateChange` → session ? `DashboardScreen` : `LoginScreen`), so login needs no navigation code
3. ✅ Aligned with the new schema:
   - datasource reads `.from("profiles")` (was `.from("User")`)
   - `UserModel`/`UserEntity`: `phone_no` (now `String?`, was `int phoneNo`), `role` (was `userRole`); nullable `department` handled correctly
   - signup metadata keys: `phone_no` (was `phoneNo`), dropped `userRole` (role is DB-managed)
4. ✅ Deleted signup presentation: `screens/signup/**` (4 files), `auth_desktop_signup_option_widget.dart`, signup screen test; removed the "Sign up" option from the login layout. Signup **data/domain** layer + its tests kept for a future invite feature.
5. ✅ `AuthBloc` provided at app root via `BlocProvider` in `CampusPulseApp`
6. ✅ Login failure feedback: `BlocListener` on `LoginScreen` shows a red `SnackBar` on `AuthFailureState`
7. ✅ Also fixed: unused `uuid` import in bloc, empty-body validator warning in `auth_textfield_widget`, declared `colorful_iconify_flutter` dependency (was transitive-only)

**Done when:** ✅ app compiles; login errors visible (live E2E in Step 10).

## Step 8 — Logout

**Status:** ✅ Done (2026-10-01)

1. ✅ `logout` added through the full stack: `AuthDatasource` → `AuthRepository` (`Either<Failure, Unit>`) → `LogoutUsecase` (`NoParams`) → `AuthBloc` (`LogoutRequested` → `AuthLoading` → `AuthInitial` on success)
2. ✅ Wired to the `TopBarProfile` avatar as a popup menu → **Sign out**
3. ✅ `_SessionGate` reacts to the cleared session automatically → `LoginScreen`
4. ✅ Bloc logout tests added (success + failure)

**Done when:** ✅ verified by unit tests; live E2E in Step 10.

## Step 9 — Dependency injection (`lib/core/di/injection_container.dart`)

**Status:** ✅ Done (2026-10-01)

Ported HEAD's `lib/dependency.dart` into the new location:

```
SupabaseClient (lazy singleton)
  → AuthDatasourceImpl
    → AuthRepositoryImpl
      → LoginUsecase / SignupUsecase / LogoutUsecase
        → AuthBloc (registerFactory)
```

`initDependencies()` called from `main()` after `Supabase.initialize`, before `runApp`.

**Done when:** ✅ `serviceLocator<AuthBloc>()` resolves at app root.

## Step 10 — Verification

**Status:** ✅ Done (2026-10-01)

1. ✅ `flutter analyze` — no issues
2. ✅ `flutter test` — **15/15 passing** (4 recovered auth test files adapted + 2 logout bloc tests + 2 widget tests)
   - datasource tests were stale at HEAD (stubs missing the `data:` arg, wrong expected message) — rewritten with full gotrue `signUp` arg matching
   - `widget_test` updated for the session gate: "renders login when signed out" + "renders dashboard shell"
3. ✅ Manual E2E (verified live by project owner):
   - cold start → `LoginScreen` ✅
   - wrong password → red SnackBar failure message ✅
   - admin login → `DashboardScreen` ✅
   - app restart → session persists ✅
   - logout (profile avatar → Sign out) → `LoginScreen` ✅
4. ✅ RLS sanity check: anon key gets `[]` from `profiles` (zero rows, no policies for anon)

---

## Risks / human-in-the-loop

| Item | Why it needs you |
|---|---|
| Step 1 `supabase login` | Interactive browser OAuth |
| Step 4 create admin user | Supabase dashboard credentials |
| Supabase dashboard access | Needed to drop legacy `"User"` table if present |

## Out of scope (later phases)

- Wiring dashboard widgets to real data (`FUTURE_FEATURES.md` → Part 6)
- Data layers for sidebar screens: Students, Staff/Faculty, Timetable, Daily Attendance, Leave Approvals, Analytics, Device Hub, Notifications, Settings
- Deferred tables: timetable, subjects, leave, devices, alerts

---

## Step 11 — Multi-institute tenancy (registry, switching, admin invitations)

**Status:** ✅ Done (2026-10-05) — see [ui/institutes/PLAN.md](../ui/institutes/PLAN.md)

1. ✅ Migration `0006_institutes_registry.sql`
   - `institutes(slug, name, code, is_active)` + `set_updated_at` trigger
   - backfilled from the `organization` values already in use; `'unassigned'` skipped
   - new RLS helpers `can_access_organization()` / `can_write_organization()`
   - the six domain policies and `profiles_select` now delegate to them, widening read+write to `super_admin`
   - `protect_profile_privileges()` untouched
2. ✅ Migration `0007_secondary_institutes.sql` — two institutes registered with **no** rows, so their data is created through the app
3. ✅ Migration `0008_account_status.sql`
   - `account_status` enum; `profiles.status` **defaults to `'invited'`** (fail-closed) and `profiles.invited_by`
   - existing rows promoted to `'active'` in the same migration
4. ✅ Edge Function `create-institute-admin` (deployed)
   - authorizes by reading `profiles.role` from the database; sets `organization` server-side
   - returns a one-time setup link instead of emailing (default mailer is rate-limited)
   - `verify_jwt = true` pinned in `config.toml`
5. ✅ Dart: `InstituteContext`, institutes data layer, `InstitutesBloc`, `SessionCubit`, DI
6. ✅ Dart: 17 institute-scoped query sites across the students and dashboard datasources; `_resolveOrganization()` deleted
7. ✅ UI: sidebar switcher (locked for regular admins), Institutes page at nav index 9, `PasswordSetupScreen` + third gate branch, real top-bar identity
8. ✅ Tests: institutes datasource + bloc, `SessionCubit`, switcher gating, institute-switch filter reset and stale-response drop, password setup screen
9. **Verification:** `flutter analyze` clean for these files; the institutes/auth/students/dashboard test suites all pass.
   > **Note:** a concurrent Staff feature was in development in the same working tree during this step;
   > `flutter analyze` and `flutter test` were clean for the institutes work but the tree as a whole was not
   > (see the handover note).
