defmodule Ennustus.ReleaseTest do
  use Ennustus.DataCase

  alias Ennustus.Games.Player
  alias Ennustus.Games.Prediction
  alias Ennustus.Games.Question
  alias Ennustus.Release
  alias Ennustus.Repo

  @entrant_file Path.join(File.cwd!(), "priv/data/worldcup2026/Kaarel Tinn.xlsx")

  # A minimal but valid .xlsx whose data sheet is named "World Cup" yet holds no
  # cells. GroupStageExporter inserts the Player, then raises on the first
  # missing game-number cell — the exact "player created, then crash" shape that
  # left an orphan player in production.
  defp corrupt_workbook(name) do
    sheet = ~s(<?xml version="1.0"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData/></worksheet>)

    workbook =
      ~s(<?xml version="1.0"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="World Cup" sheetId="1" r:id="rId1"/></sheets></workbook>)

    workbook_rels =
      ~s(<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>)

    root_rels =
      ~s(<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>)

    content_types =
      ~s(<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>)

    path = Path.join(System.tmp_dir!(), "#{name}.xlsx")

    files = [
      {~c"[Content_Types].xml", content_types},
      {~c"_rels/.rels", root_rels},
      {~c"xl/workbook.xml", workbook},
      {~c"xl/_rels/workbook.xml.rels", workbook_rels},
      {~c"xl/worksheets/sheet1.xml", sheet}
    ]

    {:ok, _} = :zip.create(String.to_charlist(path), files)
    path
  end

  describe "import_entrant/1" do
    test "imports an entrant's predictions and winner picks atomically" do
      Release.import_entrant(@entrant_file)

      player = Repo.get_by!(Player, name: "Kaarel Tinn")
      assert Repo.aggregate(from(p in Prediction, where: p.player_id == ^player.id), :count) == 104
      assert Repo.get_by(Question, player_id: player.id, question_number: 9)
      assert Repo.get_by(Question, player_id: player.id, question_number: 10)
    end

    test "rolls back the player row when the import crashes mid-way" do
      path = corrupt_workbook("Broken Entrant")

      # The failure is caught and logged; the seed must not raise.
      Release.import_entrant(path)

      refute Repo.get_by(Player, name: "Broken Entrant"),
             "a crashed import must not leave an orphan player"
    end

    test "skips a player that is already imported" do
      Release.import_entrant(@entrant_file)
      before = Repo.aggregate(Player, :count)

      Release.import_entrant(@entrant_file)

      assert Repo.aggregate(Player, :count) == before
    end
  end
end
