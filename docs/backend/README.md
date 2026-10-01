# Backend Documentation

Documentation for the backend of the **CampusPulse Attendance System (Admin)**.

Start here if you want to understand what is being built and why.

## Contents

| Document | Purpose |
|---|---|
| [PLAN.md](PLAN.md) | The step-by-step implementation plan (source of truth for progress) |
| [SCHEMA.md](SCHEMA.md) | Database schema design: tables, enums, RLS policies |
| [DECISIONS.md](DECISIONS.md) | Technology decisions and the reasoning behind them |

## What is this backend?

The admin app is currently a **UI-only dashboard shell** — every value on screen is hardcoded and there is no networking code. The backend effort restores authentication and introduces a version-controlled Supabase database schema so real data can flow into the app later.

**Scope of this phase:** database schema + authentication only.

- ✅ Supabase schema (profiles, students, staff, attendance) via CLI migrations
- ✅ Login / logout with a seeded super-admin account
- 🟡 Dashboard data wiring — KPI stats row + attendance trend chart are live; alerts, analytics cards, and roll-call table stay hardcoded until devices/alerts/timetable tables exist
- ❌ Data layers for the 9 unbuilt sidebar screens (Students, Timetable, Leave, Device Hub, …)

Those deferred items are tracked in the repo root's `FUTURE_FEATURES.md` (see "Part 6 — Data wiring").

## Current status

| Step | Description | Status |
|---|---|---|
| 1 | Install & link Supabase CLI | ✅ Done |
| 2 | Migration: core schema + auth trigger | ✅ Done |
| 3 | Migration: core domain tables | ✅ Done |
| 4 | Seed super admin | ✅ Done |
| 5 | Flutter config fixes (dotenv) | ✅ Done |
| 6 | Recover auth code from git history | ✅ Done |
| 7 | Adapt recovered auth code | ✅ Done |
| 8 | Logout wiring | ✅ Done |
| 9 | Dependency injection (`core/di`) | ✅ Done |
| 10 | Verification (analyze, tests, manual E2E) | ✅ Done |

Update the status column in [PLAN.md](PLAN.md) as steps complete.

## Background: what exists today

- **Supabase project:** `https://hlgqszvnfrbyuhaxqlof.supabase.co` — credentials in `assets/.env` (gitignored, but bundled into builds; the anon key is public by design).
- **Git history:** a complete auth stack (login/signup screens, `AuthBloc`, usecases, repository, Supabase datasource, 5 test files) existed at commit `843a7fe` and was removed during the UI rewrite. It will be **recovered from git**, not rewritten.
- **Empty skeleton:** `lib/features/dashboard/{data,domain}/` and `lib/core/di/` exist as `.gitkeep` placeholders — the intended Clean Architecture layout.
- **No SQL anywhere:** the old `User` table + trigger referenced in commit `66ea768` lived only in the Supabase dashboard. The database is empty/disposable, so the schema is rebuilt from scratch as migrations.
