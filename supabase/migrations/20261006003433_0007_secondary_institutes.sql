-- ===========================================================================
-- 0007_secondary_institutes.sql
--
-- Registers two additional institutes so the sidebar switcher is
-- exercisable immediately. Intentionally EMPTY of students/staff/attendance
-- (D8 / user decision): the data is created through the app itself via the
-- Institutes page and the Students "Add Student" dialog, which exercises the
-- real write paths rather than seeding rows around them.
-- ===========================================================================

insert into public.institutes (slug, name, code)
values
  ('apex-institute-of-tech', 'Apex Institute of Tech', 'Apex'),
  ('northgate-college',     'Northgate College',     'NGC')
on conflict (slug) do nothing;