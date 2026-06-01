-- Daily Workspace — initial schema
-- Single-user task system: projects -> tasks (self-referential tree) -> ideas.
-- done_at gives both history ("what got done") and current load ("open tasks").
-- RLS: locked to authenticated users (single-user app; every row owned by owner_id).

create extension if not exists "pgcrypto";

create table projects (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  area        text not null default 'personal',   -- personal | SBH | clinic | ...
  why         text,
  status      text not null default 'active',      -- active | done | parked
  position    int  not null default 0,
  created_at  timestamptz not null default now()
);

create table tasks (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null references auth.users(id) on delete cascade,
  project_id    uuid not null references projects(id) on delete cascade,
  parent_id     uuid references tasks(id) on delete cascade,  -- dependency tree
  text          text not null,
  optional      boolean not null default false,
  status        text not null default 'open',       -- open | done
  blocked_by    uuid references tasks(id) on delete set null,
  scheduled_for date,
  done_at       timestamptz,
  position      int not null default 0,
  created_at    timestamptz not null default now()
);

create table ideas (
  id               uuid primary key default gen_random_uuid(),
  owner_id         uuid not null references auth.users(id) on delete cascade,
  project_id       uuid references projects(id) on delete set null,
  text             text not null,
  promoted_to_task uuid references tasks(id) on delete set null,
  created_at       timestamptz not null default now()
);

create index tasks_project_idx   on tasks(project_id);
create index tasks_parent_idx    on tasks(parent_id);
create index tasks_open_idx      on tasks(owner_id, status) where status = 'open';
create index tasks_done_idx      on tasks(owner_id, done_at);

-- keep status and done_at consistent
create or replace function sync_task_done() returns trigger language plpgsql as $$
begin
  if new.status = 'done' and new.done_at is null then new.done_at := now(); end if;
  if new.status = 'open' then new.done_at := null; end if;
  return new;
end $$;
create trigger trg_sync_task_done before insert or update on tasks
  for each row execute function sync_task_done();

-- Row Level Security: every row scoped to its owner.
alter table projects enable row level security;
alter table tasks    enable row level security;
alter table ideas    enable row level security;

create policy own_projects on projects for all
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_tasks on tasks for all
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy own_ideas on ideas for all
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
