defmodule EnnustusWeb.ViewHelpers do
  def classes(classes) do
    classes
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end

  @doc "Tournament stage for a game number (FIFA WC2026 numbering)."
  def stage(n) when n in 1..72, do: :group
  def stage(n) when n in 73..88, do: :r32
  def stage(n) when n in 89..96, do: :r16
  def stage(n) when n in 97..100, do: :qf
  def stage(n) when n in 101..102, do: :sf
  def stage(103), do: :third
  def stage(104), do: :final

  @doc "Short stage label."
  def stage_label(:group), do: "Group"
  def stage_label(:r32), do: "Round of 32"
  def stage_label(:r16), do: "Round of 16"
  def stage_label(:qf), do: "Quarter-final"
  def stage_label(:sf), do: "Semi-final"
  def stage_label(:third), do: "Third place"
  def stage_label(:final), do: "Final"

  @doc "Muted accent colour band for a stage (Tailwind utility)."
  def stage_band(:group), do: "bg-[#bdbaae]"
  def stage_band(:r32), do: "bg-[#9bb0c2]"
  def stage_band(:r16), do: "bg-[#8fb2b0]"
  def stage_band(:qf), do: "bg-[#88a98a]"
  def stage_band(:sf), do: "bg-[#7d9e76]"
  def stage_band(:third), do: "bg-[#c2a06a]"
  def stage_band(:final), do: "bg-[#b08a3e]"
end
