# Ennustus — World Cup 2026 prediction league

A Phoenix LiveView app that runs a football prediction league (*ennustusliiga*).
Each entrant fills in a prediction workbook; the app imports those picks, scores
them against the real results, and shows a live standings board.

- **Public scoreboard** at `/` — players × matches, ranked by points.
- **Admin page** at `/admin` (HTTP basic auth) — enter match results and apply
  the champion / third-place bonuses.

## Stack

- Elixir / Phoenix LiveView
- **SQLite** (via `ecto_sqlite3`) — a single file, no database server
- [`mise`](https://mise.jdx.dev) for the toolchain (see `.tool-versions`:
  Erlang 28.1, Elixir 1.18.4-otp-28)
- Deployed on [Fly.io](https://fly.io)

## Local development

```sh
mise install     # install Erlang/Elixir per .tool-versions
mix setup        # deps.get + create/migrate the SQLite DB + seed (fixtures + entrants)
mix phx.server   # http://localhost:4001
```

The dev database is a local file (`ennustus_dev.db`); there is no Postgres/Docker
dependency. `mix setup` seeds via `priv/repo/seeds.exs`, which calls the
idempotent `Ennustus.Release.seed_worldcup2026/0`. Tests use their own
`ennustus_test*.db`.

```sh
mix test
```

## Tournament data & scoring

### Game numbering (FIFA WC2026)

| Stage | Game numbers |
|---|---|
| Group stage | 1–72 |
| Round of 32 | 73–88 |
| Round of 16 | 89–96 |
| Quarter-finals | 97–100 |
| Semi-finals | 101–102 |
| Third-place match | 103 |
| Final | 104 |

### Scoring (`Ennustus.Games.Scorer`)

- **Group games** — exact score = 12; correct outcome = `10 − goal-difference
  errors`; wrong outcome = negative goal-difference penalty.
- **Knockout games** — points = (number of your predicted teams that actually
  reached that round) × a per-stage coefficient: R32 = 10, R16 = 12, QF = 15,
  SF = 18, third-place match = 22, Final = 20.
- **Bonuses** — correct champion pick = 30, correct third-place winner = 25
  (applied from the admin page once games 104 and 103 are finished).

## Importing entrants (exporters)

Each entrant's prediction workbook lives in `priv/data/worldcup2026/<name>.xlsx`.
The importers are in `lib/ennustus/worldcup2026/`:

- `MatchesExporter` — seeds the 72 group fixtures and 32 knockout placeholders.
- `GroupStageExporter` — a player's 72 group-stage score predictions.
- `PlayoffStageExporter` — a player's 32 knockout bracket team picks.
- `WinnerExporter` — a player's champion (Q9) and third-place-winner (Q10) picks.
- `QuestionsExporter` — the 15 extra-question answers (Q11–Q25, 10 pts each) read
  from the consolidated `LISAKÜSIMUSTE VASTUSED.xlsx`. Skips players with no
  workbook and players already imported, so admin answer-markings survive a
  re-run.

### Seeding

`Ennustus.Release.seed/0` ties them together and is **idempotent**:

- seeds the match fixtures only when no matches exist yet (never clobbers
  results already entered through the admin page);
- imports each `*.xlsx` entrant, **skipping any player already imported**.

Safe to re-run. To add new entrants, drop their workbook into
`priv/data/worldcup2026/` and run it again — only the new files are imported.

`seed_worldcup2026/0` also imports the extra-question answers. To (re)import only
those — e.g. after editing `LISAKÜSIMUSTE VASTUSED.xlsx` — run the questions
exporter on its own.

```sh
# locally (app already running):
mix run -e 'Ennustus.Release.seed_worldcup2026()'

# locally, extra questions only:
mix run -e 'Ennustus.Worldcup2026.QuestionsExporter.process()'

# production, extra questions only (starts the repo, then imports):
fly ssh console --app <app> --command \
  "/app/bin/ennustus eval 'Ennustus.Release.seed_questions()'"
```

## Admin page

`/admin` is protected by HTTP basic auth. Credentials come from
`config :ennustus, :admin_auth` — defaulting to `admin` / `admin` in dev, and
required via the `ADMIN_USERNAME` / `ADMIN_PASSWORD` env vars in production.

Enter goals/teams/status per match, then click **Apply winner bonuses** once the
final (104) and third-place match (103) are finished to mark champion /
third-place picks correct.

## Deployment (Fly.io)

The app uses **SQLite on a persistent Fly volume**. Migrations run on app boot
(`Ennustus.Application` starts an `Ecto.Migrator` child when
`:run_migrations_on_boot` is set), because Fly's `release_command` machine does
not mount the data volume.

One-time setup:

```sh
fly volumes create data --size 1 --app <app>          # mounted at /data
fly secrets set \
  ADMIN_USERNAME=<user> \
  ADMIN_PASSWORD=<pass> \
  SECRET_KEY_BASE="$(mix phx.gen.secret)" \
  --app <app>
fly scale count 1 --app <app>                         # SQLite = single writer
```

`DATABASE_PATH` (`/data/ennustus.db`) and the volume mount are already declared
in `fly.toml`.

Deploy and seed:

```sh
fly deploy
fly ssh console --app <app> --command "/app/bin/ennustus eval 'Ennustus.Release.seed()'"
```

Notes:

- Commit the `priv/data/worldcup2026/*.xlsx` files so they are baked into the
  image (they are not git-ignored).
- SQLite is single-writer, so run **one** machine; back up by snapshotting the
  Fly volume.
- The `Dockerfile` toolchain is kept in sync with `.tool-versions`.
