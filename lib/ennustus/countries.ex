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

  def shorten(country_name) do
    country_name
    |> String.slice(0..2)
    |> String.upcase()
  end
end
