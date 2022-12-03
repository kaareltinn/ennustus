# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ennustus.Repo.insert!(%Ennustus.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

if Ennustus.Repo.all(Ennustus.Games.Match) |> Enum.empty?() do
  matches =
    "[[1,\"Qatar\",0,2,\"Ecuador\",166],[2,\"Senegal\",1,2,\"Netherlands\",166],[3,\"England\",2,0,\"Iran\",166],[4,\"United States\",1,1,\"Wales\",166],[5,\"Argentina\",2,0,\"Saudi Arabia\",166],[6,\"Denmark\",2,1,\"Tunisia\",166],[7,\"Mexico\",2,1,\"Poland\",166],[8,\"France\",1,1,\"Australia\",166],[9,\"Morocco\",1,2,\"Croatia\",166],[10,\"Germany\",2,0,\"Japan\",166],[11,\"Spain\",1,2,\"Costa Rica\",166],[12,\"Belgium\",2,0,\"Canada\",166],[13,\"Switzerland\",2,1,\"Cameroon\",166],[14,\"Uruguay\",2,1,\"Korea Republic\",166],[15,\"Portugal\",1,0,\"Ghana\",166],[16,\"Brazil\",2,0,\"Serbia\",166],[17,\"Wales\",2,0,\"Iran\",166],[18,\"Qatar\",0,2,\"Senegal\",166],[19,\"Netherlands\",2,1,\"Ecuador\",166],[20,\"England\",2,1,\"United States\",166],[21,\"Tunisia\",1,2,\"Australia\",166],[22,\"Poland\",2,0,\"Saudi Arabia\",166],[23,\"France\",1,2,\"Denmark\",166],[24,\"Argentina\",2,1,\"Mexico\",166],[25,\"Japan\",1,2,\"Costa Rica\",166],[26,\"Belgium\",2,0,\"Morocco\",166],[27,\"Croatia\",1,0,\"Canada\",166],[28,\"Spain\",1,2,\"Germany\",166],[29,\"Cameroon\",1,1,\"Serbia\",166],[30,\"Korea Republic\",1,0,\"Ghana\",166],[31,\"Brazil\",2,1,\"Switzerland\",166],[32,\"Portugal\",1,1,\"Uruguay\",166],[33,\"Ecuador\",2,1,\"Senegal\",166],[34,\"Netherlands\",2,0,\"Qatar\",166],[35,\"Wales\",1,2,\"England\",166],[36,\"Iran\",0,2,\"United States\",166],[37,\"Australia\",1,3,\"Denmark\",166],[38,\"Tunisia\",1,2,\"France\",166],[39,\"Poland\",1,3,\"Argentina\",166],[40,\"Saudi Arabia\",0,2,\"Mexico\",166],[41,\"Croatia\",1,2,\"Belgium\",166],[42,\"Canada\",1,1,\"Morocco\",166],[43,\"Japan\",0,2,\"Spain\",166],[44,\"Costa Rica\",1,3,\"Germany\",166],[45,\"Ghana\",1,2,\"Uruguay\",166],[46,\"Korea Republic\",1,2,\"Portugal\",166],[47,\"Serbia\",1,2,\"Switzerland\",166],[48,\"Cameroon\",1,2,\"Brazil\",166]]"
    |> Jason.decode!()
    |> Enum.map(fn [num, hteam, _, _, ateam, _] ->
      %{
        game_number: num,
        home_team: hteam,
        away_team: ateam,
        status: :not_started,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)

  Ennustus.Repo.insert_all(Ennustus.Games.Match, matches)
end

if Ennustus.Games.list_playoff_matches() |> Enum.empty?() do
  data =
    49..64
    |> Enum.map(fn game_number ->
      %{
        game_number: game_number,
        home_team: "TBD",
        away_team: "TBD",
        status: :not_started,
        inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
        updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
      }
    end)

  Ennustus.Repo.insert_all(Ennustus.Games.Match, data)
end

match_results =
  [
    %{
      game_number: 1,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 2,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 3,
      home_goals: 6,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 4,
      home_goals: 1,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 5,
      home_goals: 1,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 6,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 7,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 8,
      home_goals: 4,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 9,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 10,
      home_goals: 1,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 11,
      home_goals: 7,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 12,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 13,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 14,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 15,
      home_goals: 3,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 16,
      home_goals: 2,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 17,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 18,
      home_goals: 1,
      away_goals: 3,
      status: :finished
    },
    %{
      game_number: 19,
      home_goals: 1,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 20,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 21,
      home_goals: 0,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 22,
      home_goals: 2,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 23,
      home_goals: 2,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 24,
      home_goals: 2,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 25,
      home_goals: 0,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 26,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 27,
      home_goals: 4,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 28,
      home_goals: 1,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 29,
      home_goals: 3,
      away_goals: 3,
      status: :finished
    },
    %{
      game_number: 30,
      home_goals: 2,
      away_goals: 3,
      status: :finished
    },
    %{
      game_number: 31,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 32,
      home_goals: 2,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 33,
      home_goals: 1,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 34,
      home_goals: 2,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 35,
      home_goals: 0,
      away_goals: 3,
      status: :finished
    },
    %{
      game_number: 36,
      home_goals: 0,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 37,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 38,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 39,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 40,
      home_goals: 1,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 41,
      home_goals: 0,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 42,
      home_goals: 1,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 43,
      home_goals: 2,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 44,
      home_goals: 2,
      away_goals: 4,
      status: :finished
    },
    %{
      game_number: 45,
      home_goals: 0,
      away_goals: 2,
      status: :finished
    },
    %{
      game_number: 46,
      home_goals: 2,
      away_goals: 1,
      status: :finished
    },
    %{
      game_number: 47,
      home_goals: 2,
      away_goals: 3,
      status: :finished
    },
    %{
      game_number: 48,
      home_goals: 1,
      away_goals: 0,
      status: :finished
    },
    %{
      game_number: 49,
      home_team: "Netherlands",
      away_team: "United States",
      status: :finished
    },
    %{
      game_number: 50,
      home_team: "Argentina",
      away_team: "Australia",
      status: :finished
    },
    %{
      game_number: 51,
      home_team: "England",
      away_team: "Senegal",
      status: :finished
    },
    %{
      game_number: 52,
      home_team: "France",
      away_team: "Poland",
      status: :finished
    },
    %{
      game_number: 53,
      home_team: "Japan",
      away_team: "Croatia",
      status: :finished
    },
    %{
      game_number: 54,
      home_team: "Brazil",
      away_team: "Korea Republic",
      status: :finished
    },
    %{
      game_number: 55,
      home_team: "Morocco",
      away_team: "Spain",
      status: :finished
    },
    %{
      game_number: 56,
      home_team: "Portugal",
      away_team: "Switzerland",
      status: :finished
    }
  ]
  |> Enum.each(fn %{game_number: game_number} = result ->
    Ennustus.Repo.get_by(Ennustus.Games.Match, game_number: game_number)
    |> Ennustus.Games.update_match(result)
  end)

import Ecto.Query

questions_query =
  from q in Ennustus.Games.Question,
    where:
      (q.question_number == 2 and q.answer == "Wales") or
        (q.question_number == 3 and q.answer == "Inglismaa") or
        (q.question_number == 4 and q.answer == "4") or
        (q.question_number == 6 and q.answer == "Inglismaa") or
        (q.question_number == 6 and q.answer == "Hispaania") or
        (q.question_number == 7 and q.answer == "Costa Rica") or
        (q.question_number == 8 and q.answer == "Mehhiko"),
    select: q

Ennustus.Repo.all(questions_query)
|> Enum.map(&Ennustus.Games.Question.changeset(&1, %{correct: true}))
|> Enum.each(&Ennustus.Repo.update(&1))
