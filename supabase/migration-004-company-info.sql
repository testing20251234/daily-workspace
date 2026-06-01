-- migration-004-company-info
-- Company reference info (UEN, D-U-N-S, registered address, SSIC, etc.), surfaced on
-- company.html. Gated behind the same single-user login + RLS as the rest of the app.
-- Key-value shape so fields can be added/removed without a schema change; the page
-- renders one copy button per row.
--
-- Seed rows are loaded directly into the DB (single-user, public-safe registry fields)
-- and are intentionally NOT committed here — this repo is public.

create table company_info (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references auth.users(id) on delete cascade,
  entity      text not null,            -- grouping key: 'SBH' | 'AHP' | 'HL' | 'OFFICERS'
  label       text not null,            -- field name (shown + copyable)
  value       text not null,            -- field value (the copy payload)
  position    int  not null default 0,  -- order within entity
  created_at  timestamptz not null default now()
);

alter table company_info enable row level security;

create policy own_company_info on company_info for all
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
