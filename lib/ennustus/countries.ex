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
end
