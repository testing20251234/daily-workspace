# Daily Workspace

A single-user, login-gated daily task workspace. Cream/brown house aesthetic, Supabase-backed.

## What it is

The daily list is **derived**, not authored. Truth lives in Supabase:

- `projects` — long-lived (personal / SBH / clinic / …)
- `tasks` — a self-referential dependency tree; `done_at` gives both history and current load
- `ideas` — the parking lot

"Today" = every open task + anything done today, grouped by project. Optional tasks don't count toward a goal's %. Finishing a goal's last required step throws a small celebration. Ticks sync everywhere (no more copy-leftovers).

## Architecture

| Piece | What |
|-------|------|
| Supabase project | `daily-workspace` (ref `ekgvjhngsorjgavozhhf`, ap-southeast-1) — **isolated**, not shared with prod (Stripe / attendance) |
| `index.html` | single-page app: Supabase auth + the workspace UI |
| `config.js` | Supabase URL + publishable key (RLS-protected, safe to commit) |
| `supabase/migration-001-init.sql` | schema + RLS + done-sync trigger |

## Auth

Single user, email + password. RLS scopes every row to `owner_id = auth.uid()`.

## Run locally

```
open index.html
```

## Deploy (later)

Static — GitHub Pages or any static host. `config.js` ships as-is (publishable key only).

## The daily loop with Claude

1. You dump tasks/ideas in chat.
2. Claude queries open tasks + recent done, runs `/break`, writes task rows.
3. You open the app, tick through the day. State syncs.
