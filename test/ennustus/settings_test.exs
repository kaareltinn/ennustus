defmodule Ennustus.SettingsTest do
  use Ennustus.DataCase

  alias Ennustus.Settings

  describe "boolean settings" do
    test "get_boolean/2 returns the default when unset" do
      assert Settings.get_boolean("missing") == false
      assert Settings.get_boolean("missing", true) == true
    end

    test "set_boolean/2 stores and round-trips a value" do
      {:ok, _} = Settings.set_boolean("flag", true)
      assert Settings.get_boolean("flag") == true

      {:ok, _} = Settings.set_boolean("flag", false)
      assert Settings.get_boolean("flag") == false
    end
  end
end
