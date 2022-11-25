defmodule Foobar.GamesTest do
  use Foobar.DataCase

  alias Foobar.Games

  describe "predictions" do
    alias Foobar.Games.Prediction

    import Foobar.GamesFixtures

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
end
