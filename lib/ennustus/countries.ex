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
      "England" => :gb_eng,
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
      "Ukraine" => :uk,
      "Poland" => :pl,
      "Scotland" => :gb_sct,
      "Hungary" => :hu,
      "Croatia" => :hr,
      "Serbia" => :rs,
      "Albania" => :al
    }
    |> Map.get(country_name)
  end

  def shorten(country_name) do
    country_name
    |> String.slice(0..2)
    |> String.upcase()
  end
end
