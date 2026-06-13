defmodule Ennustus.Worldcup2026.ExportersTest do
  use Ennustus.DataCase

  alias Ennustus.Games.Player
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  alias Ennustus.Worldcup2026.MatchesExporter
  alias Ennustus.Worldcup2026.QuestionsExporter

  @extra_questions_file Path.join(File.cwd!(), "priv/data/worldcup2026/LISAKÜSIMUSTE VASTUSED.xlsx")

  describe "MatchesExporter" do
    test "seeds 72 group fixtures with real teams" do
      MatchesExporter.export(:group_stage)
      matches = Repo.all(Ennustus.Games.Match)
      assert length(matches) == 72
      numbers = matches |> Enum.map(& &1.game_number) |> Enum.sort()
      assert numbers == Enum.to_list(1..72)
      first = Enum.find(matches, &(&1.game_number == 1))
      assert {first.home_team, first.away_team} == {"Mexico", "South Africa"}
    end

    test "seeds 32 knockout placeholders" do
      MatchesExporter.export(:playoffs)
      matches = Repo.all(Ennustus.Games.Match)
      numbers = matches |> Enum.map(& &1.game_number) |> Enum.sort()
      assert numbers == Enum.to_list(73..104)
      assert Enum.all?(matches, &is_nil(&1.home_team))
    end
  end

  describe "QuestionsExporter against the extra-questions file" do
    defp questions(player_id) do
      Repo.all(from q in Question, where: q.player_id == ^player_id, select: q)
      |> Map.new(&{&1.question_number, &1})
    end

    test "imports the 15 extra-question answers as question_number 11-25 for a matched player" do
      {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Sander Orion"}))

      QuestionsExporter.process(@extra_questions_file)

      qs = questions(player.id)
      assert Map.keys(qs) |> Enum.sort() == Enum.to_list(11..25)
      # column 1 (Kaardid) -> Q11, column 15 -> Q25; numeric answers stringified.
      assert qs[11].answer == "Argentiina"
      assert qs[19].answer == "9"
      assert qs[24].answer == "Messi "
      assert qs[25].answer == "Mbappe"
      assert Enum.all?(Map.values(qs), &(&1.correct == false))
    end

    test "skips players who are absent from the workbook import" do
      QuestionsExporter.process(@extra_questions_file)
      # "Kertu-Liina Kaseorg" appears in the file but has no Player row.
      refute Repo.get_by(Player, name: "Kertu-Liina Kaseorg")
    end

    test "is idempotent: re-running does not duplicate or reset answers" do
      {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: "Sander Orion"}))

      QuestionsExporter.process(@extra_questions_file)
      Repo.update_all(from(q in Question, where: q.player_id == ^player.id), set: [correct: true])

      QuestionsExporter.process(@extra_questions_file)

      qs = questions(player.id)
      assert map_size(qs) == 15
      assert Enum.all?(Map.values(qs), &(&1.correct == true)), "re-import must not reset markings"
    end

    test "questions/0 exposes the 15 numbered titles" do
      titles = QuestionsExporter.questions()
      assert length(titles) == 15
      assert {11, "Kaardid"} in titles
      assert {25, "Mbappe/Kane/Vini Jr/Haaland/Yamal"} in titles
    end
  end
end
