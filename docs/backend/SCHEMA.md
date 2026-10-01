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

## Deferred tables (later phases)

Not part of this phase — listed so the schema direction is clear:

- `subjects`, `class_sections`, `timetable_periods` (Timetable screen)
- `leave_requests` (Leave Approvals screen — sidebar badge shows 12 pending)
- `devices` / IoT terminals (Device Hub, live status chip)
- `alerts` / notifications (Urgent Alerts card)
- `audit_log` (roll-call audit actions)

## Legacy note

The pre-rewrite app used a quoted capital-U `"User"` table populated by an ad-hoc dashboard trigger. Since the database is disposable, that table is dropped and replaced by `profiles` + `handle_new_user()`. The Flutter datasource is updated accordingly (`.from("profiles")`).
