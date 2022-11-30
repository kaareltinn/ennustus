defmodule Ennustus.Games.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :answer, :string
    field :correct, :boolean, default: false
    field :question_number, :integer
    field :player_id, :integer

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:answer, :correct, :question_number, :player_id])
    |> validate_required([:answer, :correct, :question_number, :player_id])
  end
end
