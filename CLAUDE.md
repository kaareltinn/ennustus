# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Phoenix LiveView app running a football prediction league for FIFA World Cup
2026. Entrants submit a `.xlsx` prediction workbook; the app imports the picks,
scores them against real results entered via an admin page, and renders a live
standings board. See `README.md` for the full domain rules (game numbering,
scoring formula, Fly.io deploy). This file covers commands and architecture.

## Commands

The toolchain is pinned in `.tool-versions` (Erlang 28.1, Elixir 1.18.4-otp-28);
use `mise install` to match it.

```sh
mix setup        # deps.get + create/migrate SQLite DB + seed fixtures & entrants
mix phx.server   # http://localhost:4001  (NOTE: port 4001, not the default 4000)
mix test                                   # runs ecto.create/migrate then tests
mix test test/ennustus/games/scorer_test.exs          # single file
mix test test/ennustus/games/scorer_test.exs:42       # single test by line
mix ecto.reset                             # drop + recreate + migrate + seed
```

- **Do not start or kill `mix phx.server`** — the user runs it themselves on
  `:4001`. Verify UI changes with Playwright against the running server.
- Storage is **SQLite** (`ennustus_dev.db`, `ennustus_test.db`), a single file —
  no Postgres/Docker. SQLite is single-writer; production runs one Fly machine.

## Architecture

### Data model (`lib/ennustus/games/`)

Four flat schemas, joined by integer `player_id` (no Ecto associations):

- `Player` — one per entrant.
- `Match` — the 104 tournament games, keyed by `game_number`; carries
  `home_goals`/`away_goals`/`status` (`:not_started | :in_progress | :finished`)
  filled in by admins.
- `Prediction` — an entrant's score guess for one match.
- `Question` — quiz/bonus answers. `question_number` 1–8 are quiz questions
  (10 pts each when `correct`); **9 = champion pick, 10 = third-place pick**.

### Scoring is pure and computed on read

`Ennustus.Games.Scorer.score/5` takes matches, predictions-by-player, question
scores, and the two bonus prediction maps, and returns a sorted standings list.
**Scores are never persisted** — the LiveViews recompute on every render from
current match results. `game_number` ranges drive everything: group games
(< 73) score by exact-score/outcome/goal-diff; knockout games (73–104) score by
how many of your predicted teams actually reached that stage × a per-stage
coefficient (`get_playoff_stage` / `get_playoff_stage_coef`).

### Games context (`lib/ennustus/games.ex`)

The query/command boundary. `@games_order` defines the canonical display
ordering of game numbers (group → R32 → R16 → QF → SF → 3rd → final), applied
DB-agnostically via `order_index`. `apply_winner_bonuses/0` marks question 9/10
correctness once games 104/103 are finished (called from the admin page).

> **Gotcha:** `list_playoff_matches/0,1` uses game numbers **49–64** — that is
> stale Euro 2024 numbering, not the WC2026 knockout range (73–104). Scoring and
> seeding use the correct 73–104 range; treat those `list_playoff_matches`
> helpers as suspect / legacy.

### Workbook import pipeline (`lib/ennustus/worldcup2026/`)

This is the active import path. `Ennustus.Release.seed_worldcup2026/0`
orchestrates it idempotently:

1. `MatchesExporter.export(:group_stage)` + `export(:playoffs)` — seeds the 104
   fixtures (hardcoded group pairings + empty 73–104), only when no matches exist.
2. For each `.xlsx` in `priv/data/worldcup2026/` not already imported (matched by
   player name parsed from the filename): `GroupStageExporter` →
   `PlayoffStageExporter` → `WinnerExporter` read fixed cell addresses out of the
   workbook and insert `Prediction`/`Question` rows.

`Worldcup2026.Workbook.load/1` resolves the "World Cup" sheet **by name** to its
physical `sheetN.xml` index (parsing `workbook.xml` + rels) and extracts only
that one sheet — extracting all ~30 sheets at once OOMs on small machines.

Seeding is idempotent and safe to re-run; it never clobbers entered results and
skips already-imported entrants. Run when the server is up:
`mix run -e 'Ennustus.Release.seed_worldcup2026()'`.

> The `lib/ennustus/euro2024/` and top-level `lib/ennustus/*_exporter.ex`
> modules are the previous tournament's importers, kept for reference. New work
> goes through `Ennustus.Worldcup2026.*`.

### Web (`lib/ennustus_web/`)

Two real pages, wired in `router.ex`:

- `Games.PredictionsLive` at `/` — public scoreboard.
- `Admin.MatchesLive` at `/admin` — enter results + apply bonuses, behind HTTP
  basic auth (`admin_basic_auth`, credentials from `config :ennustus, :admin_auth`).

A full `phx.gen.auth` user system (registration/login/settings, `UserAuth`,
`Accounts` context) exists but is **not used** by the league flow — neither
public nor admin pages require a logged-in user. `counter_live.ex` and
`foobar_web.ex` are leftover scaffold.

### Production seeding quirk

Migrations run on app boot (`Ennustus.Application` starts an `Ecto.Migrator`
child when `:run_migrations_on_boot` is set), not via a release command —
Fly's release-command machine does not mount the data volume.
