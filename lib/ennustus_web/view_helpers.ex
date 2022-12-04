defmodule EnnustusWeb.ViewHelpers do
  def classes(classes) do
    classes
    |> Enum.filter(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
    |> Enum.join(" ")
  end
end
