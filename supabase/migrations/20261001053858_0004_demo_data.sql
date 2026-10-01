-- ============================================================================
-- Migration 0004 — Demo data
--
-- Seeds a demo dataset so the dashboard renders real numbers:
--   * 50 students across 5 departments (organization = 'CampusPulse')
--   * 8 staff/lecturers
--   * 7 days of attendance records (including today), ~85% present
--
-- All values are deterministic (md5-based pseudo-random) so re-deriving the
-- data during development is stable. Safe on a disposable database only.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Students (50)
-- ---------------------------------------------------------------------------
insert into public.students (organization, student_no, name, email, department, status)
select
  'CampusPulse',
  'STU-' || lpad(g::text, 4, '0'),
  initcap(fn.v || ' ' || ln.v),
  lower(replace(fn.v || '.' || ln.v || g || '@campuspulse.edu', ' ', '')),
  dept.v,
  case when mod(g, 17) = 0
       then 'inactive'::public.student_status
       else 'active'::public.student_status
  end
from generate_series(1, 50) as g
cross join lateral (
  select (array['Aarav','Priya','Rohan','Ananya','Kabir','Meera',
                'Arjun','Diya','Vihaan','Ishaan','Sanya','Rehan'])[mod(g, 12) + 1] as v
) as fn
cross join lateral (
  select (array['Sharma','Patel','Iyer','Rao','Nair','Singh',
                'Gupta','Verma','Mehta','Kapoor','Das','Joshi'])[mod(g * 7, 12) + 1] as v
) as ln
cross join lateral (
  select (array['Computer Science','Electronics','Mechanical','Civil','Mathematics'])[mod(g, 5) + 1] as v
) as dept;

-- ---------------------------------------------------------------------------
-- 2. Staff (8)
-- ---------------------------------------------------------------------------
insert into public.staff (organization, name, email, department, staff_type)
select
  'CampusPulse',
  n.v,
  lower(replace(n.v, ' ', '.')) || '@campuspulse.edu',
  d.v,
  'lecturer'
from (values
  ('Dr. Anita Rao'), ('Prof. Vikram Singh'), ('Dr. Neha Gupta'),
  ('Prof. Rahul Mehta'), ('Dr. Sunita Kapoor'), ('Prof. Arun Joshi'),
  ('Dr. Kavita Nair'), ('Prof. Manoj Iyer')
) as n(v)
cross join lateral (
  select (array['Computer Science','Electronics','Mechanical','Civil','Mathematics'])[
    mod(abs(hashtext(n.v)), 5) + 1
  ] as v
) as d;

-- ---------------------------------------------------------------------------
-- 3. Attendance — last 7 days including today (~85% present / 5% late /
--    6% absent / 4% on_leave; ~30% recorded via roll-call/manual)
-- ---------------------------------------------------------------------------
insert into public.attendance_records (organization, student_id, status, date, method)
select
  'CampusPulse',
  s.id,
  case
    when h < 85 then 'present'::public.attendance_status
    when h < 90 then 'late'::public.attendance_status
    when h < 96 then 'absent'::public.attendance_status
    else           'on_leave'::public.attendance_status
  end,
  d::date,
  case
    when mod(h, 10) < 7 then 'biometric'::public.attendance_method
    when mod(h, 10) = 7 then 'roll_call'::public.attendance_method
    else                   'manual'::public.attendance_method
  end
from public.students s
cross join generate_series(current_date - 6, current_date, interval '1 day') as d
cross join lateral (
  select abs(hashtext(s.student_no || d::text)) % 100 as h
) as x
where s.organization = 'CampusPulse';
