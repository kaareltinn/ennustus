defmodule Ennustus.Repo.Migrations.ChangeUserIdToPlayerId do
  use Ecto.Migration

  def change do
    alter table(:predictions) do
      remove :user_id
      add :player_id, references(:players)
    end
  end
end
