defmodule Foobar.Repo do
  use Ecto.Repo,
    otp_app: :foobar,
    adapter: Ecto.Adapters.Postgres
end
