defmodule Ennustus.Repo do
  use Ecto.Repo,
    otp_app: :ennustus,
    adapter: Ecto.Adapters.SQLite3
end
