defmodule FiveHundo.Word do

  def count(""), do: 0
  def count(text) do
    text
    |> String.split(word_delimiter_expression())
    |> Enum.count
  end

  defp word_delimiter_expression, do: ~r/ |\n/
end
