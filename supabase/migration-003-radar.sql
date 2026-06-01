-- Daily Workspace — migration 003: L4 resurfacing ("On your radar")
-- A watch-item is a PARKED project + a resurface cadence + a cached note. The app shows due ones in
-- a quiet radar strip; /today surfaces overdue ones and stamps last_surfaced_at. No new table needed.

alter table projects add column resurface_every_days int;        -- cadence in days; null = not watched
alter table projects add column last_surfaced_at timestamptz;    -- when /today last surfaced it
alter table projects add column radar_note text;                 -- cached context / links (don't re-search)
