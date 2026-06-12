# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run by `mix ecto.setup` / `mix ecto.reset` (and therefore
# `mix setup`).
#
# Seeding is delegated to Ennustus.Release.seed_worldcup2026/0, which loads the
# match fixtures and every entrant's predictions from priv/data/worldcup2026
# using the Ennustus.Worldcup2026 exporters. It is idempotent: safe to re-run,
# it never duplicates rows and never clobbers results entered via the admin page.

Ennustus.Release.seed_worldcup2026()
