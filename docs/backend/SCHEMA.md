# Database Schema

Supabase (Postgres) schema for the CampusPulse admin backend. Applied as versioned migrations in `supabase/migrations/`.

- Naming: **snake_case** everywhere (`profiles`, not `"User"`)
- Multi-tenancy: every domain row carries `organization`, scoped by RLS
- The database is empty/disposable — no migrations need to be backward-compatible

Enum types use a check-free approach (`app_role`, status enums) so future values can be added with `alter type … add value`.

---

## Enums

```sql
create type public.app_role as enum ('super_admin', 'admin');
-- (defined in 0001)

create type public.student_status  as enum ('active', 'inactive');
create type public.attendance_status as enum ('present', 'absent', 'late', 'on_leave');
create type public.attendance_method as enum ('biometric', 'manual', 'roll_call');
-- (defined in 0002)
```

---

## Migration 0001 — Core schema (auth)

### `profiles`

One row per authenticated user, 1:1 with `auth.users`.

| Column | Type | Constraints |
|---|---|---|
| `id` | `uuid` | PK, `references auth.users(id) on delete cascade` |
| `email` | `text` | `not null`, `unique` |
| `name` | `text` | `not null` |
| `phone_no` | `text` | nullable (text — preserves leading zeros) |
| `department` | `text` | nullable |
| `organization` | `text` | `not null` |
| `role` | `app_role` | `not null default 'admin'` |
| `created_at` | `timestamptz` | `not null default now()` |
| `updated_at` | `timestamptz` | `not null default now()` |

**Trigger `handle_new_user()`** — `after insert on auth.users`:
copies `new.raw_user_meta_data` → `name`, `department`, `phone_no` (accepts legacy `phoneNo` key), `organization`, plus `new.email`. Gives normal users the default `admin` role; the super admin is promoted manually (Step 4 of [PLAN.md](PLAN.md)).

**Helpers** (`security definer`, `set search_path = public`):
- `current_organization()` → `organization` of the calling user's profile
- `current_app_role()` → `role` of the calling user's profile *(named `_app_role` because `current_role` is a reserved SQL keyword)*

Used inside RLS policies to avoid recursive policy evaluation on `profiles`. `EXECUTE` revoked from `anon`/`PUBLIC`, granted to `authenticated` + `service_role`.

**Guard trigger `profiles_protect_privileges`** — `before update`: raises if a logged-in non-super-admin tries to change `role`, `organization`, or `id` (evaluated against the OLD row, so it can't be bypassed by changing the value first).

**RLS policies:**

| Policy | Command | Rule |
|---|---|---|
| `profiles_select` | `select` | `auth.role() = 'authenticated'` and (`id = auth.uid()` or `organization = current_organization()`) |
| `profiles_update_own` | `update` | `id = auth.uid()` (row-level column guard handled by `profiles_protect_privileges`) |
| `profiles_update_admin` | `update` | `current_app_role() = 'super_admin'` |

No `insert`/`delete` policies for clients — user creation happens via the Supabase admin API/dashboard (which bypasses RLS).

---

## Migration 0002 — Core domain

All three tables share: `id uuid primary key default gen_random_uuid()`, `organization text not null`, `created_at/updated_at timestamptz not null default now()`, RLS enabled, `updated_at` trigger.

### `students`

| Column | Type | Notes |
|---|---|---|
| `student_no` | `text` | `not null`, unique per org (`unique(organization, student_no)`) |
| `name` | `text` | `not null` |
| `email` | `text` | nullable |
| `department` | `text` | nullable |
| `status` | `student_status` | `not null default 'active'` |

### `staff`

| Column | Type | Notes |
|---|---|---|
| `profile_id` | `uuid` | nullable → `profiles(id) on delete set null` (links login-capable instructors/admins) |
| `name` | `text` | `not null` |
| `email` | `text` | nullable |
| `department` | `text` | nullable |
| `staff_type` | `text` | e.g. `lecturer`, `assistant`, `admin` |

### `attendance_records`

| Column | Type | Notes |
|---|---|---|
| `student_id` | `uuid` | `not null` → `students(id) on delete cascade` |
| `status` | `attendance_status` | `not null` |
| `date` | `date` | `not null` |
| `method` | `attendance_method` | `not null` |
| `recorded_by` | `uuid` | nullable → `profiles(id) on delete set null` |
| | | `unique(student_id, date)` — one record per student per day |

**RLS (all domain tables):**

| Policy | Command | Rule |
|---|---|---|
| `*_select` | `select` | `organization = current_organization()` |
| `*_write` | `insert`/`update`/`delete` | `organization = current_organization()` and `current_app_role() in ('super_admin','admin')` |

---

## Migration 0003 — Seed super admin

Promotes the manually created admin profile to `role = 'super_admin'`, sets `organization = 'CampusPulse'`, and replaces the email-style name with the local part. A guard raises if the profile row is missing. No passwords in the repo — the migration only touches the already-created row.

---

## Migration 0004 — Demo data

Deterministic seed for the disposable database (`organization = 'CampusPulse'`):

- **50 students** across 5 departments — `md5()`-based names/emails, a few flagged `inactive`
- **8 staff/lecturers**
- **7 days of `attendance_records`** (including today), ~85% `present`, 5% `late`, 6% `absent`, 4% `on_leave`, `method = 'biometric'`

All values are md5-derived, so re-deriving the data during development is stable. Feeds the dashboard KPI row and attendance trend chart.

---

## Deferred tables (later phases)

Not part of this phase — listed so the schema direction is clear:

- `subjects`, `class_sections`, `timetable_periods` (Timetable screen)
- `leave_requests` (Leave Approvals screen — sidebar badge shows 12 pending)
- `devices` / IoT terminals (Device Hub, live status chip)
- `alerts` / notifications (Urgent Alerts card)
- `audit_log` (roll-call audit actions)

## Legacy note

The pre-rewrite app used a quoted capital-U `"User"` table populated by an ad-hoc dashboard trigger. Since the database is disposable, that table is dropped and replaced by `profiles` + `handle_new_user()`. The Flutter datasource is updated accordingly (`.from("profiles")`).

---

## Migration 0006 — Institutes registry

`public.institutes` is the registry of institutes. It exists because the tenant key was free text: there was nothing to *list*, so no UI could offer a choice.

| Column | Type | Constraints / Notes |
|---|---|---|
| `id` | `uuid` | `primary key default gen_random_uuid()` |
| `slug` | `text` | `not null unique` — the tenant key, matches `students.organization` etc. |
| `name` | `text` | `not null` — display name |
| `code` | `text` | optional short label; **not** fabricated by the backfill |
| `is_active` | `boolean` | `not null default true` — deactivation is a soft delete |
| `created_at` / `updated_at` | `timestamptz` | `set_updated_at` trigger |

`slug` and `students.organization` are linked **by convention, not by foreign key** — deliberate, to avoid rewriting the three domain tables and every policy.

**Backfill:** distinct `organization` values from `students`/`staff`/`attendance_records`/`profiles`, skipping the `'unassigned'` trigger fallback. Already-cased slugs (`CampusPulse`) are preserved as-is; others are humanised (`north_gate` ? `North Gate`).

### RLS helpers (new)

`can_access_organization(target text)` and `can_write_organization(target text)` — both `security definer`, `stable`, `search_path = public`, execute revoked from `PUBLIC`/`anon`. They replace the inline `organization = current_organization()` predicates:

- **read** — `current_app_role() = 'super_admin' or target = current_organization()`
- **write** — super admin for any institute; an `admin` only within their own

A regular admin's effective access is unchanged by migration 0006; only `super_admin` widens.

## Migration 0007 — Secondary institutes

Registers `apex-institute-of-tech` and `northgate-college`, **with no students/staff/attendance**. Their data is created through the app, which exercises the real write paths instead of seeding around them.

## Migration 0008 — Account status

| Column | Type | Notes |
|---|---|---|
| `profiles.status` | `public.account_status` | `not null default 'invited'` — **fail-closed** |
| `profiles.invited_by` | `uuid` | `references public.profiles(id) on delete set null` |

`account_status` is `('invited', 'active')`. An account invited by a super admin cannot enter the app until it sets a password on `PasswordSetupScreen`, which flips it to `active`.

Because the column defaults to `'invited'`, existing rows were promoted in the same migration — otherwise the seeded super admin would have been locked out of their own app.

`protect_profile_privileges()` is unchanged: it guards `role`/`organization`/`id`, and self-updating `status` is already allowed by `profiles_update_own`.

## Edge function — `create-institute-admin`

Holds `service_role`, which is why it exists: creating an `auth.users` row cannot be done from a client, and the anon key must never gain that power.

| Check | Result |
|---|---|
| Caller identity | `auth.getUser(token)` — gateway also enforces `verify_jwt` |
| Caller role | `profiles.role = 'super_admin'`, **read from the database**, never from the request |
| Institute | must exist and be active in the registry |
| Email | shape-checked; an existing account returns `409` |

It creates the user unconfirmed with `user_metadata.organization` set **server-side**, so the client-supplied tenant in `handle_new_user()` is never used, and returns a one-time setup link rather than emailing it (Supabase's default mailer is rate-limited).

The Dart side needs no new dependency: `supabase_flutter 2.12.4` resolves to `supabase 2.10.6`, which exposes `FunctionsClient`.
