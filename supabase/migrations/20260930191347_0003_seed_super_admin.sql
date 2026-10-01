-- ============================================================================
-- Migration 0003 — Seed super admin
--
-- Promotes the manually-created dashboard auth user to super_admin and places
-- it in the "CampusPulse" organization. The profile row itself was created by
-- the handle_new_user trigger (0001).
--
-- To seed a different admin: change the email below, or create the user in
-- the dashboard and run an equivalent UPDATE.
-- ============================================================================

do $$
declare
  v_email constant text := 'preetham2005105@gmail.com';
  v_count integer;
begin
  select count(*) into v_count
    from public.profiles
   where lower(email) = lower(v_email);

  if v_count = 0 then
    raise exception 'Super admin profile not found for % — create the user in the dashboard first', v_email;
  end if;
end $$;

update public.profiles
   set role = 'super_admin',
       organization = 'CampusPulse'
 where lower(email) = lower('preetham2005105@gmail.com');

-- Give email-style names (from the trigger fallback) a readable form.
update public.profiles
   set name = split_part(email, '@', 1)
 where lower(email) = lower('preetham2005105@gmail.com')
   and name = email;
