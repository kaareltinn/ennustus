defmodule Ennustus.Repo.Migrations.CreateAnswerKeys do
  use Ecto.Migration

  def change do
    create table(:answer_keys) do
      add :question_number, :integer, null: false
      add :answer, :string

      timestamps()
    end

    create unique_index(:answer_keys, [:question_number])
  end
end
