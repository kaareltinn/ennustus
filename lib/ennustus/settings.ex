defmodule Ennustus.Settings do
  @moduledoc """
  Persisted key/value application settings, with boolean helpers.
  """

  alias Ennustus.Repo
  alias Ennustus.Settings.Setting

  @doc """
  Returns the boolean setting for `key`, or `default` when it is unset.
  """
  def get_boolean(key, default \\ false) do
    case Repo.get_by(Setting, key: key) do
      %Setting{value: "true"} -> true
      %Setting{value: "false"} -> false
      _ -> default
    end
  end

  @doc """
  Stores the boolean `value` for `key`.
  """
  def set_boolean(key, value) when is_boolean(value) do
    %Setting{}
    |> Setting.changeset(%{key: key, value: to_string(value)})
    |> Repo.insert(
      on_conflict: {:replace, [:value, :updated_at]},
      conflict_target: :key
    )
  end
end
