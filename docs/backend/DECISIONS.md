# Backend Decisions

Why the backend is built the way it is. Each decision was confirmed before implementation started.

---

## 1. Backend platform: Supabase

**Chosen over:** Firebase, custom REST API.

- A Supabase project already exists (`https://hlgqszvnfrbyuhaxqlof.supabase.co`) with credentials in `assets/.env`.
- A full auth integration (login/signup + `User` table) previously worked against it — recoverable from git history.
- `supabase_flutter` is already in `pubspec.yaml` (includes Auth, Postgres, Realtime).
- Postgres + Row Level Security covers multi-tenancy (`organization` scoping) without a custom server.

## 2. State management & DI: flutter_bloc + get_it + fpdart

**Chosen over:** Riverpod (declared but never used), Provider (not installed).

- `pubspec.yaml` declares all three; only `flutter_bloc` was ever actually used.
- The deleted auth implementation at commit `843a7fe` follows a proven, tested pattern:

  ```
  datasource → repository → usecase → bloc
                    ↑
        fpdart Either<Failure, T> for error handling
  ```

- Recovering and adapting that code is far cheaper than rewriting with a new pattern.
- Clean Architecture folders (`domain/`, `data/`, `presentation/bloc/`, `core/di/`) already exist as the intended layout.

## 3. Scope: schema + auth only

**Chosen over:** full backend (also wiring the dashboard + 9 sidebar screens), or schema only.

- The app currently has **zero** backend code and **zero** real data — auth is the foundation everything else depends on.
- `FUTURE_FEATURES.md` "Part 6 — Data wiring" already tracks the follow-on work.
- Delivering schema + working login first gives a verifiable milestone before the larger data-wiring effort.

## 4. Schema management: Supabase CLI migrations

**Chosen over:** pasting SQL into the dashboard manually.

- Schema lives in the repo as `supabase/migrations/*.sql` — version-controlled, reviewable, reproducible.
- The team had no SQL in the repo before; the old `User` table + trigger existed only in the dashboard and were lost in the rewrite.
- Requires installing the CLI and a one-time interactive `supabase login` (documented in [PLAN.md](PLAN.md) Step 1).

## 5. Account policy: seeded super admin only

**Chosen over:** open signup (the pre-rewrite default), signup + approval.

- This is an **admin** console — public self-registration should not exist.
- The super admin is created once in the Supabase dashboard and promoted via SQL.
- The recovered `SignupUsecase`/datasource code is kept (data layer only) so an admin-invited "create user" feature can reuse it later; the public signup screens are deleted.

## 6. Table naming: snake_case (`profiles`)

**Chosen over:** keeping the legacy quoted `"User"` table.

- Supabase/Postgres convention — no quoting needed in queries.
- Database is empty/disposable, so there is no migration burden.
- Requires updating the recovered datasource from `.from("User")` to `.from("profiles")` — a one-line change.
- Model maps are aligned to `phone_no` / `role` instead of `phoneNo` / `userRole`.

## 7. Schema breadth: auth + core tables

**Chosen over:** full domain schema now, or auth tables only.

- **Now:** `profiles`, `students`, `staff`, `attendance_records` — the entities auth and the first real features need.
- **Deferred:** timetable, subjects, leave, devices, alerts — designed only when their screens are built.
- Keeps the first migrations small and reviewable while still establishing the org-scoping/RLS patterns the rest will copy.

## 8. Phone number: `text`, not `int`

The legacy model stored `phoneNo` as `int` (drops leading zeros, breaks international formats). The new `profiles.phone_no` is `text`; the adapted Dart model uses `String?`.

---

## Known issues being fixed along the way

| Issue | Fix |
|---|---|
| `dotenv.load(fileName: ".env")` — flutter_dotenv 6.0.1 loads the exact path via `rootBundle.loadString`, but the asset is bundled at `assets/.env` → `FileNotFoundError` | `dotenv.load(fileName: "assets/.env")` |
| Misspelled env key `SUPABASE_API_ANNON_KEY` | Rename to `SUPABASE_API_ANON_KEY` in `.env` + code |
| `assets/.env` is bundled into builds | Acceptable: the Supabase **anon** key is public by design; RLS is the real boundary. The file stays gitignored (`.gitignore` → `.env`). |
| Recovered auth code imports deleted `core/app_colors.dart` / `core/screens/base_screen.dart` | Remap to `core/theme/app_colors.dart` / `DashboardScreen` |
