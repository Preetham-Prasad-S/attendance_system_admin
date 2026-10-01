-- ============================================================================
-- Migration 0005 — Student directory seed (45-day attendance history)
--
-- Prepares demo data for the Student Directory screen
-- (docs/ui/student-directory/PLAN.md — Phase 2):
--   1. Re-seeds attendance_records for the last 45 days (was 7) so the
--      30-day attendance log and 30-day compliance stats look realistic.
--   2. Staggers students.created_at over the last 18 months (~17% within
--      90 days) so the "Total Enrolled +N this term" KPI is meaningful.
--
-- Deterministic (md5/hashtext-based) like migration 0004 — stable on a
-- disposable database.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Attendance history: 45 days (current_date - 44 .. current_date)
--    Same distribution as 0004: ~85% present / 5% late / 6% absent /
--    4% on_leave; ~30% recorded via roll-call/manual.
-- ---------------------------------------------------------------------------
delete from public.attendance_records
where organization = 'CampusPulse';

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
cross join generate_series(current_date - 44, current_date, interval '1 day') as d
cross join lateral (
  select abs(hashtext(s.student_no || d::text)) % 100 as h
) as x
where s.organization = 'CampusPulse';

-- ---------------------------------------------------------------------------
-- 2. Stagger enrollment dates over 18 months (540 days), ~17% in last 90 days.
--    updated_at is refreshed by the students_set_updated_at trigger.
-- ---------------------------------------------------------------------------
update public.students
set created_at =
      (current_date - (abs(hashtext(student_no)) % 540))
      + (abs(hashtext(student_no || ':created')) % 86400) * interval '1 second'
where organization = 'CampusPulse';
