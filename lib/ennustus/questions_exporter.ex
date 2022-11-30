defmodule Ennustus.QuestionsExporter do
  alias Ennustus.Games.Player
  alias Ennustus.Games.Question
  alias Ennustus.Repo

  def load_file(filename) do
    Xlsxir.peek(filename, 0, 58)
  end

  def process(filename) do
    {:ok, ref} = load_file(filename)

    # {:ok, player} = Repo.get_by!(Player, name: player_name)
    data =
      Xlsxir.get_mda(ref)
      |> Enum.reject(fn {i, _} -> i == 0 end)
      |> Enum.flat_map(fn {_, row} ->
        player = Repo.get_by!(Player, name: row[0])

        [
          %{
            answer: row[1],
            correct: false,
            question_number: 1,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[2],
            correct: false,
            question_number: 2,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[3],
            correct: false,
            question_number: 3,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[4] |> trunc() |> Integer.to_string(),
            correct: false,
            question_number: 4,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[5],
            correct: false,
            question_number: 5,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[6],
            correct: false,
            question_number: 6,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[7],
            correct: false,
            question_number: 7,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[8],
            correct: false,
            question_number: 8,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[9],
            correct: false,
            question_number: 9,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          },
          %{
            answer: row[10],
            correct: false,
            question_number: 10,
            player_id: player.id,
            inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
            updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
          }
        ]
      end)

    Repo.insert_all(Question, data)

    close_file(ref)

    :ok
  end

  def reset do
    Repo.delete_all(Question)
  end

  def close_file(ref) do
    Xlsxir.close(ref)
  end
end
