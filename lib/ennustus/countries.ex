defmodule Ennustus.Countries do
  def iso_code(country_name) do
    %{
      "England" => :gb_eng,
      "Germany" => :deu,
      "Denmark" => :dnk,
      "Spain" => :esp,
      "France" => :fra,
      "Italy" => :ita,
      "Netherlands" => :nld,
      "Switzerland" => :che,
      "Belgium" => :bel,
      "Portugal" => :prt,
      "Austria" => :aut,
      "Slovakia" => :svk,
      "Slovenia" => :svn,
      "Georgia" => :geo,
      "Romania" => :rou,
      "Türkiye" => :tur,
      "Czechia" => :cze,
      "Ukraine" => :ukr,
      "Poland" => :pol,
      "Scotland" => :gb_sct,
      "Hungary" => :hun,
      "Croatia" => :hrv,
      "Serbia" => :srb,
      "Albania" => :alb
    }
    |> Map.get(country_name)
  end

  def iso_code_2(country_name) do
    %{
      "England" => :"gb-eng",
      "Germany" => :de,
      "Denmark" => :dk,
      "Spain" => :es,
      "France" => :fr,
      "Italy" => :it,
      "Netherlands" => :nl,
      "Switzerland" => :ch,
      "Belgium" => :be,
      "Portugal" => :pt,
      "Austria" => :at,
      "Slovakia" => :sk,
      "Slovenia" => :si,
      "Georgia" => :ge,
      "Romania" => :ro,
      "Türkiye" => :tr,
      "Czechia" => :cz,
      "Ukraine" => :ua,
      "Poland" => :pl,
      "Scotland" => :"gb-sct",
      "Hungary" => :hu,
      "Croatia" => :hr,
      "Serbia" => :rs,
      "Albania" => :al,
      "Mexico" => :mx,
      "South Africa" => :za,
      "Czech Rep." => :cz,
      "Rep. of Korea" => :kr,
      "Canada" => :ca,
      "Bosnia/Herzeg." => :ba,
      "Qatar" => :qa,
      "Brazil" => :br,
      "Morocco" => :ma,
      "Haiti" => :ht,
      "USA" => :us,
      "Turkey" => :tr,
      "Australia" => :au,
      "Paraguay" => :py,
      "Ecuador" => :ec,
      "Ivory Coast" => :ci,
      "Curaçao" => :cw,
      "Japan" => :jp,
      "Sweden" => :se,
      "Tunisia" => :tn,
      "IR Iran" => :ir,
      "Egypt" => :eg,
      "New Zealand" => :nz,
      "Uruguay" => :uy,
      "Saudi Arabia" => :sa,
      "Cape Verde" => :cv,
      "Norway" => :no,
      "Senegal" => :sn,
      "Iraq" => :iq,
      "Argentina" => :ar,
      "Algeria" => :dz,
      "Jordan" => :jo,
      "Colombia" => :co,
      "Uzbekistan" => :uz,
      "DR Congo" => :cd,
      "Ghana" => :gh,
      "Panama" => :pa
    }
    |> Map.get(country_name)
  end

  def shorten(country_name) do
    country_name
    |> String.slice(0..2)
    |> String.upcase()
  end

  @world_cup_2026_teams [
    "Algeria",
    "Argentina",
    "Australia",
    "Austria",
    "Belgium",
    "Bosnia/Herzeg.",
    "Brazil",
    "Canada",
    "Cape Verde",
    "Colombia",
    "Croatia",
    "Curaçao",
    "Czech Rep.",
    "DR Congo",
    "Ecuador",
    "Egypt",
    "England",
    "France",
    "Germany",
    "Ghana",
    "Haiti",
    "IR Iran",
    "Iraq",
    "Ivory Coast",
    "Japan",
    "Jordan",
    "Mexico",
    "Morocco",
    "Netherlands",
    "New Zealand",
    "Norway",
    "Panama",
    "Paraguay",
    "Portugal",
    "Qatar",
    "Rep. of Korea",
    "Saudi Arabia",
    "Scotland",
    "Senegal",
    "South Africa",
    "Spain",
    "Sweden",
    "Switzerland",
    "Tunisia",
    "Turkey",
    "USA",
    "Uruguay",
    "Uzbekistan"
  ]

  @doc "Team names that can appear in the World Cup 2026, sorted for select inputs."
  def world_cup_2026_teams, do: @world_cup_2026_teams

  @doc """
  Unicode flag emoji for a country, derived from its two-letter code. Used where
  CSS flag-icons cannot render (e.g. native `<option>` labels).
  """
  def flag_emoji(country_name) do
    case iso_code_2(country_name) do
      nil -> "🏳"
      :"gb-eng" -> "🏴󠁧󠁢󠁥󠁮󠁧󠁿"
      :"gb-sct" -> "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
      code -> regional_indicators(code)
    end
  end

  defp regional_indicators(code) do
    code
    |> to_string()
    |> String.upcase()
    |> String.to_charlist()
    |> Enum.map_join(fn char -> <<0x1F1E6 + (char - ?A)::utf8>> end)
  end
end
