defmodule Ennustus.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Ennustus.Games` context.
  """

  @doc """
  Generate a prediction.
  """
  def prediction_fixture(attrs \\ %{}) do
    {:ok, prediction} =
      attrs
      |> Enum.into(%{

      })
      |> Ennustus.Games.create_prediction()

    prediction
  end
end
