-- ============================================================================
-- Migration 0001 — Core schema (auth foundation)
--
-- Creates:
--   * public.profiles          — 1:1 with auth.users (app identity + role + org)
--   * handle_new_user trigger  — populates profiles from auth metadata
--   * helper functions         — current_organization(), current_app_role()
--   * RLS                      — no anon access; scoped reads; controlled writes
--
-- Also performs defensive cleanup of the pre-rewrite schema that existed only
-- in the Supabase dashboard (legacy "User" table + its signup trigger).
-- The database is disposable — see docs/backend/SCHEMA.md.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Legacy cleanup (pre-rewrite ad-hoc schema)
-- ---------------------------------------------------------------------------
do $$
declare
  trg record;
begin
  for trg in
    select t.tgname
      from pg_trigger t
      join pg_proc p on p.oid = t.tgfoid
     where t.tgrelid = 'auth.users'::regclass
       and not t.tgisinternal
       and p.proname = 'handle_new_user'
  loop
    execute format('drop trigger %I on auth.users', trg.tgname);
  end loop;
end $$;

drop function if exists public.handle_new_user();
drop table if exists "User";

-- ---------------------------------------------------------------------------
-- 2. Role enum
-- ---------------------------------------------------------------------------
create type public.app_role as enum ('super_admin', 'admin');

-- ---------------------------------------------------------------------------
-- 3. profiles table
-- ---------------------------------------------------------------------------
create table public.profiles (
  id            uuid primary key references auth.users (id) on delete cascade,
  email         text not null unique,
  name          text not null,
  phone_no      text,                       -- text: keeps leading zeros / +cc
  department    text,
  organization  text not null,
  role          public.app_role not null default 'admin',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

comment on table public.profiles is
  'Application identity for each authenticated user. Populated by trigger from auth.users metadata.';

-- ---------------------------------------------------------------------------
-- 4. updated_at helper (reused by later migrations)
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- ---------------------------------------------------------------------------
-- 5. handle_new_user — mirror auth.users → profiles
--    Accepts legacy metadata key "phoneNo" as well as "phone_no".
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, phone_no, department, organization)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'name', new.email),
    coalesce(
      new.raw_user_meta_data ->> 'phone_no',
      new.raw_user_meta_data ->> 'phoneNo'
    ),
    new.raw_user_meta_data ->> 'department',
    coalesce(new.raw_user_meta_data ->> 'organization', 'unassigned')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- 6. RLS helper functions (security definer → bypass RLS, no recursion)
-- ---------------------------------------------------------------------------
create or replace function public.current_organization()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select p.organization from public.profiles p where p.id = auth.uid();
$$;

create or replace function public.current_app_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select p.role from public.profiles p where p.id = auth.uid();
$$;

revoke execute on function public.current_organization(), public.current_app_role()
  from PUBLIC, anon;
grant execute on function public.current_organization(), public.current_app_role()
  to authenticated, service_role;

-- ---------------------------------------------------------------------------
-- 7. Privilege escalation guard
--    Non-super-admins may edit their own profile, but must not be able to
--    change role / organization / id. Evaluated on the OLD row values.
-- ---------------------------------------------------------------------------
create or replace function public.protect_profile_privileges()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is not null
     and public.current_app_role() is distinct from 'super_admin'
     and (new.role is distinct from old.role
          or new.organization is distinct from old.organization
          or new.id is distinct from old.id)
  then
    raise exception 'Only a super_admin can change role, organization, or id';
  end if;
  return new;
end;
$$;

create trigger profiles_protect_privileges
  before update on public.profiles
  for each row execute function public.protect_profile_privileges();

-- ---------------------------------------------------------------------------
-- 8. Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles enable row level security;

-- Read: own row, or anyone in the same organization.
create policy profiles_select
  on public.profiles
  for select
  to authenticated
  using (
    id = auth.uid()
    or organization = public.current_organization()
  );

-- Write: users may edit their own row (guarded by profiles_protect_privileges).
create policy profiles_update_own
  on public.profiles
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Write: super_admins may edit any row.
create policy profiles_update_admin
  on public.profiles
  for update
  to authenticated
  using (public.current_app_role() = 'super_admin')
  with check (true);

-- No insert/delete policies → clients cannot create or remove users.
-- Users are created via the Supabase admin API / dashboard (bypass RLS).

-- Explicit grants (deterministic even if default privileges change).
grant select, update on table public.profiles to authenticated;
grant select, update on table public.profiles to service_role;
