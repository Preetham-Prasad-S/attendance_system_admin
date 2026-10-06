-- ===========================================================================
-- 0008_account_status.sql
--
-- Adds the invited/active lifecycle for admin accounts created through the
-- app (D11). A super_admin invites an admin from the Institutes page; the
-- invitee lands on a password-setup screen and only then becomes 'active'.
--
-- Fail-closed: the column defaults to 'invited', so any profile that has not
-- explicitly completed setup cannot enter the shell.
-- ===========================================================================

create type public.account_status as enum ('invited', 'active');

alter table public.profiles
  add column status public.account_status not null default 'invited';

alter table public.profiles
  add column invited_by uuid references public.profiles (id) on delete set null;

comment on column public.profiles.status is
  'invited = invited by a super_admin but has not set a password yet; active = may enter the app.';

-- Existing profiles predate invitations and already have working logins.
-- The 'invited' default above applied to them too, so promote them now.
update public.profiles
set status = 'active'
where status = 'invited';

-- Listing the accounts of an institute when assigning admins.
create index profiles_organization_idx on public.profiles (organization);