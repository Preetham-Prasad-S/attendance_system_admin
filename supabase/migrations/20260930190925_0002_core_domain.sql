-- ============================================================================
-- Migration 0002 — Core domain tables
--
-- Creates: public.students, public.staff, public.attendance_records
-- All rows are organization-scoped and protected by RLS (see docs/backend/SCHEMA.md).
--
-- Explicitly deferred to later phases:
--   subjects, class_sections, timetable, leave_requests,
--   devices (IoT terminals), alerts/notifications, audit_log
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Enums
-- ---------------------------------------------------------------------------
create type public.student_status   as enum ('active', 'inactive');
create type public.attendance_status as enum ('present', 'absent', 'late', 'on_leave');
create type public.attendance_method as enum ('biometric', 'manual', 'roll_call');

-- ---------------------------------------------------------------------------
-- 2. students
-- ---------------------------------------------------------------------------
create table public.students (
  id            uuid primary key default gen_random_uuid(),
  organization  text not null,
  student_no    text not null,
  name          text not null,
  email         text,
  department    text,
  status        public.student_status not null default 'active',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint students_org_student_no_key unique (organization, student_no)
);

comment on table public.students is 'Student roster, scoped by organization.';

create trigger students_set_updated_at
  before update on public.students
  for each row execute function public.set_updated_at();

create index students_organization_idx on public.students (organization);

-- ---------------------------------------------------------------------------
-- 3. staff
-- ---------------------------------------------------------------------------
create table public.staff (
  id            uuid primary key default gen_random_uuid(),
  organization  text not null,
  profile_id    uuid references public.profiles (id) on delete set null,
  name          text not null,
  email         text,
  department    text,
  staff_type    text not null default 'lecturer',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table public.staff is
  'Staff/faculty directory. profile_id links login-capable staff to their profile.';

create trigger staff_set_updated_at
  before update on public.staff
  for each row execute function public.set_updated_at();

create index staff_organization_idx on public.staff (organization);

-- ---------------------------------------------------------------------------
-- 4. attendance_records
-- ---------------------------------------------------------------------------
create table public.attendance_records (
  id            uuid primary key default gen_random_uuid(),
  organization  text not null,
  student_id    uuid not null references public.students (id) on delete cascade,
  status        public.attendance_status not null,
  date          date not null,
  method        public.attendance_method not null,
  recorded_by   uuid references public.profiles (id) on delete set null,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  constraint attendance_records_student_date_key unique (student_id, date)
);

comment on table public.attendance_records is
  'One attendance status per student per day (upserted by biometric/manual/roll-call).';

create trigger attendance_records_set_updated_at
  before update on public.attendance_records
  for each row execute function public.set_updated_at();

create index attendance_records_org_date_idx on public.attendance_records (organization, date);
create index attendance_records_date_idx on public.attendance_records (date);

-- ---------------------------------------------------------------------------
-- 5. Row Level Security
-- ---------------------------------------------------------------------------
alter table public.students          enable row level security;
alter table public.staff             enable row level security;
alter table public.attendance_records enable row level security;

-- students
create policy students_select
  on public.students for select to authenticated
  using (organization = public.current_organization());

create policy students_write
  on public.students for all to authenticated
  using (organization = public.current_organization()
         and public.current_app_role() in ('super_admin', 'admin'))
  with check (organization = public.current_organization());

-- staff
create policy staff_select
  on public.staff for select to authenticated
  using (organization = public.current_organization());

create policy staff_write
  on public.staff for all to authenticated
  using (organization = public.current_organization()
         and public.current_app_role() in ('super_admin', 'admin'))
  with check (organization = public.current_organization());

-- attendance_records
create policy attendance_records_select
  on public.attendance_records for select to authenticated
  using (organization = public.current_organization());

create policy attendance_records_write
  on public.attendance_records for all to authenticated
  using (organization = public.current_organization()
         and public.current_app_role() in ('super_admin', 'admin'))
  with check (organization = public.current_organization());

-- ---------------------------------------------------------------------------
-- 6. Explicit grants (deterministic, alongside Supabase default privileges)
-- ---------------------------------------------------------------------------
grant select, insert, update, delete on table public.students           to authenticated, service_role;
grant select, insert, update, delete on table public.staff              to authenticated, service_role;
grant select, insert, update, delete on table public.attendance_records to authenticated, service_role;
