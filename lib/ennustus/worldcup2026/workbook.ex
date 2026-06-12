defmodule Ennustus.Worldcup2026.Workbook do
  @moduledoc """
  Loads the "World Cup" worksheet from an entrant's prediction workbook.

  The workbooks contain ~30 sheets and the data sheet is not always first —
  some files prepend a hidden "Export Summary" sheet — so we resolve the
  "World Cup" sheet by name to its physical worksheet index and extract only
  that one sheet. Extracting every sheet at once (multi_extract/2 with a nil
  index) parses them all into memory and OOMs on small machines.
  """

  @data_sheet "World Cup"

  @doc """
  Returns `{:ok, table_id}` for the "World Cup" worksheet of `filename`.
  """
  def load(filename) do
    Xlsxir.multi_extract(filename, world_cup_index(filename), false, extract_to: :memory)
  end

  # Xlsxir addresses worksheets by their physical `sheetN.xml` number (index
  # N-1), so we map the "World Cup" sheet name to that file via the workbook
  # relationships, reading only the two small XML files needed.
  defp world_cup_index(filename) do
    {:ok, files} =
      :zip.unzip(String.to_charlist(filename), [
        :memory,
        {:file_list, [~c"xl/workbook.xml", ~c"xl/_rels/workbook.xml.rels"]}
      ])

    workbook_xml = file_binary(files, "xl/workbook.xml")
    rels_xml = file_binary(files, "xl/_rels/workbook.xml.rels")

    sheet_number(rels_xml, sheet_rid(workbook_xml, @data_sheet)) - 1
  end

  defp file_binary(files, name) do
    Enum.find_value(files, fn {fname, bin} -> if to_string(fname) == name, do: bin end)
  end

  defp sheet_rid(workbook_xml, sheet_name) do
    [_, rid] = Regex.run(~r/<sheet\b[^>]*name="#{sheet_name}"[^>]*r:id="(rId\d+)"/, workbook_xml)
    rid
  end

  defp sheet_number(rels_xml, rid) do
    [_, number] =
      Regex.run(~r/Id="#{rid}"[^>]*Target="worksheets\/sheet(\d+)\.xml"/, rels_xml)

    String.to_integer(number)
  end
end
