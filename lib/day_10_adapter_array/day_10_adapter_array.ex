defmodule AdventOfCode.Day10AdapterArray do
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day10AdapterArray
    iex> data = "28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3"
    iex> data |> resolve_jolt_chain_differences_value()
    220
  """
  def resolve_jolt_chain_differences_value(jolts_values) do
    jolts_values
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort()
    |> add_corner_jolts()
    |> jolts_diff(0, 0, 0)
  end

  defp add_corner_jolts(jolts), do: jolts ++ [List.last(jolts) + 3]

  defp jolts_diff([], _previous, jolts1, jolts3), do: jolts1 * jolts3

  defp jolts_diff([jolt | jolts], previous, jolts1, jolts3) when jolt - previous == 1 do
    jolts_diff(jolts, jolt, jolts1 + 1, jolts3)
  end

  defp jolts_diff([jolt | jolts], _previous, jolts1, jolts3) do
    jolts_diff(jolts, jolt, jolts1, jolts3 + 1)
  end
end
