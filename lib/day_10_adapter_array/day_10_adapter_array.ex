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
    |> parse_jolts()
    |> add_corner_jolts()
    |> jolts_diff(0, 0, 0)
  end

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day10AdapterArray
    iex> data = "28 33 18 42 31 14 46 20 48 47 24 23 49 45 19 38 39 11 1 32 25 35 8 17 7 9 4 2 34 10 3"
    iex> data |> count_adapters_arrangements()
    19208
  """
  def count_adapters_arrangements(jolts_values) do
    jolts_values
    |> parse_jolts()
    |> get_all_arrangements()
  end

  def parse_jolts(jolts_values) do
    jolts_values
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Enum.sort()
  end

  defp add_corner_jolts(jolts), do: jolts ++ [List.last(jolts) + 3]

  defp jolts_diff([], _previous, jolts1, jolts3), do: jolts1 * jolts3

  defp jolts_diff([jolt | jolts], previous, jolts1, jolts3) when jolt - previous == 1 do
    jolts_diff(jolts, jolt, jolts1 + 1, jolts3)
  end

  defp jolts_diff([jolt | jolts], _previous, jolts1, jolts3) do
    jolts_diff(jolts, jolt, jolts1, jolts3 + 1)
  end

  defp get_all_arrangements(jolts) do
    jolts = [0 | jolts]

    jolts
    |> jolts_to_map()
    |> create_map_for_connections(jolts)
    |> get_all_arrangements(%{0 => 1})
  end

  defp get_all_arrangements(jolts_map, connections_jolts_map) do
    new_connections_map =
      connections_jolts_map
      |> Map.keys()
      |> generate_next_connections(connections_jolts_map, jolts_map, %{})

    if(new_connections_map == connections_jolts_map) do
      Map.values(new_connections_map) |> Enum.at(0)
    else
      get_all_arrangements(jolts_map, new_connections_map)
    end
  end

  defp generate_next_connections([], _connections_jolts_map, _jolts_map, new_connections_map) do
    new_connections_map
  end

  defp generate_next_connections([key | keys], connections_jolts_map, jolts_map, new_connections_map) do
    new_connections_map =
      jolts_map
      |> Map.get(key)
      |> Enum.map(&{&1, Map.get(connections_jolts_map, key)})
      |> Enum.into(%{})
      |> Map.merge(new_connections_map, fn _, v1, v2 -> v1 + v2 end)

    generate_next_connections(keys, connections_jolts_map, jolts_map, new_connections_map)
  end

  defp jolts_to_map(jolts), do: jolts |> Enum.map(&{&1, 0}) |> Enum.into(%{})

  defp create_map_for_connections(map, [jolt | []]), do: Map.put(map, jolt, [jolt])

  defp create_map_for_connections(map, [jolt | jolts]) do
    map
    |> Map.put(jolt, jolts |> Enum.take_while(&(&1 <= jolt + 3)))
    |> create_map_for_connections(jolts)
  end
end
