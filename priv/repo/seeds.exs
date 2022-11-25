# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Foobar.Repo.insert!(%Foobar.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
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

Foobar.Repo.insert_all(Foobar.Games.Match, matches)
