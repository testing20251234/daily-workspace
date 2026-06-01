-- Daily Workspace — migration 002: two-person split (ZW + Steph)
-- Single owner (ZW) still owns every row; RLS is unchanged. `assignee` is a view filter
-- so the app can render per-person pages (ZW / Steph / Both). Existing rows default to 'ZW'.

alter table tasks
  add column assignee text not null default 'ZW'
  check (assignee in ('ZW','Steph','shared'));

-- project-level default the engine/app use when creating tasks; also groups whole projects.
alter table projects
  add column default_assignee text not null default 'ZW'
  check (default_assignee in ('ZW','Steph','shared'));

create index tasks_assignee_idx on tasks(owner_id, assignee) where status = 'open';
