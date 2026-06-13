defmodule Ennustus.Games.AnswerKey do
  @moduledoc """
  The admin-entered canonical correct answer for an extra question
  (`question_number` 11–25). A player's answer scores when it matches this,
  compared case-insensitively and ignoring surrounding whitespace.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "answer_keys" do
    field :question_number, :integer
    field :answer, :string

    timestamps()
  end

  @doc false
  def changeset(answer_key, attrs) do
    answer_key
    |> cast(attrs, [:question_number, :answer])
    |> validate_required([:question_number])
    |> unique_constraint(:question_number)
  end
end
