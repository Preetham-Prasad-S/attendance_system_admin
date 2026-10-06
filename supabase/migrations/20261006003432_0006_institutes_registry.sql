-- ===========================================================================
-- 0006_institutes_registry.sql
--
-- Adds public.institutes as the registry of institutes, and lets a
-- super_admin read/write across every institute instead of only the one
-- named on their own profiles row.
--
-- The tenant key stays `organization text` on the domain tables (D1: no
-- column rewrite). `institutes.slug` is linked to it by convention, not by
-- foreign key — documented in docs/backend/SCHEMA.md.
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- 1. Institutes registry
-- ---------------------------------------------------------------------------
create table public.institutes (
  id         uuid primary key default gen_random_uuid(),
  slug       text not null unique,      -- matches students/staff/attendance_records.organization
  name       text not null,
  code       text,                      -- optional short label, not fabricated on backfill
  is_active  boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.institutes is
  'Registry of institutes. slug is the tenant key used by the organization column on domain tables.';

create trigger institutes_set_updated_at
  before update on public.institutes
  for each row execute function public.set_updated_at();

create index institutes_is_active_idx on public.institutes (is_active);

-- ---------------------------------------------------------------------------
-- 2. Backfill from the organization values already in use
--    Preserves already-cased slugs ('CampusPulse') and humanises the rest
--    ('north_gate' -> 'North Gate'). Skips the 'unassigned' trigger fallback.
-- ---------------------------------------------------------------------------
insert into public.institutes (slug, name)
select distinct
  org,
  case
    when org ~ '^[A-Z]' then org
    else initcap(replace(org, '_', ' '))
  end
from (
  select organization as org from public.students
  union
  select organization from public.staff
  union
  select organization from public.attendance_records
  union
  select organization from public.profiles
) existing
where org is not null
  and org <> ''
  and org <> 'unassigned'
on conflict (slug) do nothing;

-- ---------------------------------------------------------------------------
-- 3. RLS helper functions (security definer → bypass RLS, no recursion)
--    can_access_organization: may this caller read rows for <target>?
--    can_write_organization:  may this caller mutate rows for <target>?
--    A super_admin passes both for any institute; an admin only for its own.
-- ---------------------------------------------------------------------------
create or replace function public.can_access_organization(target text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'super_admin'
      or target = public.current_organization();
$$;

create or replace function public.can_write_organization(target text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.current_app_role() = 'super_admin'
      or (
        target = public.current_organization()
        and public.current_app_role() = 'admin'
      );
$$;

revoke execute on function
  public.can_access_organization(text),
  public.can_write_organization(text)
  from PUBLIC, anon;
grant execute on function
  public.can_access_organization(text),
  public.can_write_organization(text)
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 4. Institutes RLS
--    Read: any authenticated caller may see the registry of names.
--    Write: super_admin only (this is what backs the Institutes page).
-- ---------------------------------------------------------------------------
alter table public.institutes enable row level security;

create policy institutes_select
  on public.institutes for select to authenticated
  using (true);

create policy institutes_insert
  on public.institutes for insert to authenticated
  with check (public.current_app_role() = 'super_admin');

create policy institutes_update
  on public.institutes for update to authenticated
  using (public.current_app_role() = 'super_admin')
  with check (public.current_app_role() = 'super_admin');

create policy institutes_delete
  on public.institutes for delete to authenticated
  using (public.current_app_role() = 'super_admin');

grant select on table public.institutes to authenticated, service_role;
grant insert, update, delete on table public.institutes to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 5. Widen domain policies for super_admin
--    Identical to 0002 except the organization predicate is delegated to the
--    can_access_/can_write_ helpers. A regular admin's effective access is
--    unchanged: read+write within their own institute only.
-- ---------------------------------------------------------------------------
drop policy if exists students_select on public.students;
create policy students_select
  on public.students for select to authenticated
  using (public.can_access_organization(organization));

drop policy if exists students_write on public.students;
create policy students_write
  on public.students for all to authenticated
  using (public.can_write_organization(organization))
  with check (public.can_write_organization(organization));

drop policy if exists staff_select on public.staff;
create policy staff_select
  on public.staff for select to authenticated
  using (public.can_access_organization(organization));

drop policy if exists staff_write on public.staff;
create policy staff_write
  on public.staff for all to authenticated
  using (public.can_write_organization(organization))
  with check (public.can_write_organization(organization));

drop policy if exists attendance_records_select on public.attendance_records;
create policy attendance_records_select
  on public.attendance_records for select to authenticated
  using (public.can_access_organization(organization));

drop policy if exists attendance_records_write on public.attendance_records;
create policy attendance_records_write
  on public.attendance_records for all to authenticated
  using (public.can_write_organization(organization))
  with check (public.can_write_organization(organization));

-- ---------------------------------------------------------------------------
-- 6. Widen profiles_select so a super_admin can list accounts when assigning
--    them to an institute. profiles_update_admin already permits super_admins
--    to edit any row, so reassigning profiles.organization needs no new policy.
--    protect_profile_privileges() is deliberately untouched: switching
--    institutes never mutates a profile row.
-- ---------------------------------------------------------------------------
drop policy if exists profiles_select on public.profiles;
create policy profiles_select
  on public.profiles for select to authenticated
  using (
    id = auth.uid()
    or public.can_access_organization(organization)
  );