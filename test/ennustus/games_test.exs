defmodule Ennustus.GamesTest do
  use Ennustus.DataCase

  alias Ennustus.Games

  describe "predictions" do
    alias Ennustus.Games.Prediction

    import Ennustus.GamesFixtures

    @invalid_attrs %{}

    test "list_predictions/0 returns all predictions" do
      prediction = prediction_fixture()
      assert Games.list_predictions() == [prediction]
    end

    test "get_prediction!/1 returns the prediction with given id" do
      prediction = prediction_fixture()
      assert Games.get_prediction!(prediction.id) == prediction
    end

    test "create_prediction/1 with valid data creates a prediction" do
      valid_attrs = %{}

      assert {:ok, %Prediction{} = prediction} = Games.create_prediction(valid_attrs)
    end

    test "create_prediction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_prediction(@invalid_attrs)
    end

    test "update_prediction/2 with valid data updates the prediction" do
      prediction = prediction_fixture()
      update_attrs = %{}

      assert {:ok, %Prediction{} = prediction} = Games.update_prediction(prediction, update_attrs)
    end

    test "update_prediction/2 with invalid data returns error changeset" do
      prediction = prediction_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.update_prediction(prediction, @invalid_attrs)
      assert prediction == Games.get_prediction!(prediction.id)
    end

    test "delete_prediction/1 deletes the prediction" do
      prediction = prediction_fixture()
      assert {:ok, %Prediction{}} = Games.delete_prediction(prediction)
      assert_raise Ecto.NoResultsError, fn -> Games.get_prediction!(prediction.id) end
    end

    test "change_prediction/1 returns a prediction changeset" do
      prediction = prediction_fixture()
      assert %Ecto.Changeset{} = Games.change_prediction(prediction)
    end
  end

  describe "extra questions" do
    alias Ennustus.Games.Player
    alias Ennustus.Games.Question
    alias Ennustus.Repo

    defp player(name) do
      {:ok, player} = Repo.insert(Player.changeset(%Player{}, %{name: name}))
      player
    end

    defp answer(player, question_number, answer) do
      Repo.insert!(%Question{
        player_id: player.id,
        question_number: question_number,
        answer: answer,
        correct: false
      })
    end

    test "extra_questions/0 lists the 15 questions with their stored answer" do
      Games.set_extra_answer(11, "Argentiina")

      questions = Games.extra_questions()
      assert length(questions) == 15
      assert Enum.find(questions, &(&1.number == 11)) == %{number: 11, title: "Kaardid", answer: "Argentiina"}
      assert Enum.find(questions, &(&1.number == 12)).answer == nil
    end

    test "set_extra_answer/2 marks matching answers correct, case- and space-insensitively" do
      p1 = player("p1")
      p2 = player("p2")
      p3 = player("p3")
      answer(p1, 11, "Argentiina")
      answer(p2, 11, "argentiina ")
      answer(p3, 11, "Holland")

      Games.set_extra_answer(11, "Argentiina")

      assert Repo.get_by(Question, player_id: p1.id, question_number: 11).correct
      assert Repo.get_by(Question, player_id: p2.id, question_number: 11).correct
      refute Repo.get_by(Question, player_id: p3.id, question_number: 11).correct
    end

    test "set_extra_answer/2 matches non-ASCII answers case-insensitively" do
      p1 = player("p1")
      p2 = player("p2")
      answer(p1, 13, "Šveits")
      answer(p2, 14, "DŽEKO")

      Games.set_extra_answer(13, "šveits")
      Games.set_extra_answer(14, "Džeko")

      assert Repo.get_by(Question, player_id: p1.id, question_number: 13).correct
      assert Repo.get_by(Question, player_id: p2.id, question_number: 14).correct
    end

    test "set_extra_answer/2 re-marks when the answer changes" do
      p1 = player("p1")
      answer(p1, 11, "Holland")
      Games.set_extra_answer(11, "Argentiina")
      refute Repo.get_by(Question, player_id: p1.id, question_number: 11).correct

      Games.set_extra_answer(11, "Holland")
      assert Repo.get_by(Question, player_id: p1.id, question_number: 11).correct
    end

    test "blank answer clears all markings for the question" do
      p1 = player("p1")
      answer(p1, 11, "Argentiina")
      Games.set_extra_answer(11, "Argentiina")
      assert Repo.get_by(Question, player_id: p1.id, question_number: 11).correct

      Games.set_extra_answer(11, "")
      refute Repo.get_by(Question, player_id: p1.id, question_number: 11).correct
    end

    test "extra_answers_by_player/0 returns answers, correctness and score, ranked" do
      p1 = player("alice")
      p2 = player("bob")
      answer(p1, 11, "Argentiina")
      answer(p1, 12, "Holland")
      answer(p2, 11, "Brasiilia")
      Games.set_extra_answer(11, "Argentiina")

      [first, second] = Games.extra_answers_by_player()

      assert first.name == "alice"
      assert first.score == 10
      assert first.answers[11] == %{answer: "Argentiina", correct: true}
      assert first.answers[12] == %{answer: "Holland", correct: false}

      assert second.name == "bob"
      assert second.score == 0
    end

    test "question_scores/0 awards 10 points per correct extra question" do
      p1 = player("p1")
      answer(p1, 11, "Argentiina")
      answer(p1, 12, "Holland")
      Games.set_extra_answer(11, "Argentiina")
      Games.set_extra_answer(12, "Holland")
      # champion pick (question 9) must not count toward extra-question scoring
      answer(p1, 9, "Brazil") |> then(&Repo.update!(Ecto.Changeset.change(&1, correct: true)))

      assert %{score: 20} = Games.question_scores() |> Map.get(p1.id) |> List.first()
    end
  end
end
