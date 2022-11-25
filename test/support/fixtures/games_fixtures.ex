defmodule Foobar.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Foobar.Games` context.
  """

  @doc """
  Generate a prediction.
  """
  def prediction_fixture(attrs \\ %{}) do
    {:ok, prediction} =
      attrs
      |> Enum.into(%{

      })
      |> Foobar.Games.create_prediction()

    prediction
  end
end
