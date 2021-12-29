defmodule AdventOfCode.Day24LobbyLayout do

  # import AdventOfCode.Day24LobbyLayout
  # file = "lib/day_24_lobby_layout/input.txt" |> File.read!()
  def get_tiles_switched_black(data) do
    data
    |> String.split("\n")
    |> Enum.map(&get_coordinates/1)
    |> Enum.map(&move/1)
    |> colour()
    |> Map.to_list()
    |> Enum.filter(fn {_tile, colour} -> colour == :black end)
    |> Enum.count()
  end

  def get_tiles_switched_black_after(data, days) do
    data
    |> String.split("\n")
    |> Enum.map(&get_coordinates/1)
    |> Enum.map(&move/1)
    |> colour()
    |> colour_by_adjacents_for_days(days)
    |> Map.to_list()
    |> Enum.filter(fn {_tile, colour} -> colour == :black end)
    |> Enum.count()
  end

  defp colour(tiles), do: colour(tiles, %{})
  defp colour([], map), do: map
  defp colour([tile | tiles], map) do
    colour(tiles, Map.update(map, tile, :black, &(if &1 == :black, do: :white, else: :black)))
  end

  def colour_by_adjacents_for_days(map, 0), do: map
  def colour_by_adjacents_for_days(map, days) do
    map = map
    |> Map.to_list()
    |> evolve_with_adjacents(map)

    map = map
    |> Map.to_list()
    |> colour_by_adjacents(map, [])

    colour_by_adjacents_for_days(map, days - 1)
  end

  def evolve_with_adjacents([], map), do: map
  def evolve_with_adjacents([{_position, :white} | tiles], map), do: evolve_with_adjacents(tiles, map)
  def evolve_with_adjacents([{position, :black} | tiles], map) do
    map = position
    |> adjacents()
    |> Enum.reduce(map, &(Map.put_new(&2, &1, :white)))

    evolve_with_adjacents(tiles, map)
  end

  defp colour_by_adjacents([], _map,  new_tiles), do: Enum.into(new_tiles, %{})
  defp colour_by_adjacents([{position, _} = tile | tiles], map, new_tiles) do
    colour_by_adjacents(tiles, map, [{position, colour_by_adjacents(map, tile)} | new_tiles])
  end

  defp colour_by_adjacents(map, {position, :white}) do
    map
    |> get_colour_by_adjacents(position)
    |> (fn count -> if count == 2, do: :black, else: :white end).()
  end

  defp colour_by_adjacents(map, {position, :black}) do
    map
    |> get_colour_by_adjacents(position)
    |> (fn count -> if count == 0 or  count > 2, do: :white, else: :black end).()
  end

  defp get_colour_by_adjacents(map, position) do
    position
    |> adjacents()
    |> Enum.map(&Map.get(map, &1))
    |> Enum.filter(&(&1 == :black))
    |> Enum.count()
  end

  defp adjacents(position) do
    [["se"], ["sw"], ["ne"], ["nw"], ["w"], ["e"]]
    |> Enum.map(&(move(position, &1)))
  end

  defp move(moves), do: move({0,0,0}, moves)
  defp move(current_position, []), do: current_position
  defp move({r,s,q}, ["se" | moves]), do: move({r+1, s, q-1}, moves)
  defp move({r,s,q}, ["sw" | moves]), do: move({r+1, s-1, q}, moves)
  defp move({r,s,q}, ["ne" | moves]), do: move({r-1, s+1, q}, moves)
  defp move({r,s,q}, ["nw" | moves]), do: move({r-1, s, q+1}, moves)
  defp move({r,s,q}, ["e" | moves]), do: move({r, s+1, q-1}, moves)
  defp move({r,s,q}, ["w" | moves]), do: move({r, s-1, q+1}, moves)

  defp get_coordinates(moves), do: get_coordinates(moves, [])
  defp get_coordinates("", coordinates), do: Enum.reverse(coordinates)
  defp get_coordinates(<<"se", moves::binary>>, coordinates), do: get_coordinates(moves, ["se" | coordinates])
  defp get_coordinates(<<"sw", moves::binary>>, coordinates), do: get_coordinates(moves, ["sw" | coordinates])
  defp get_coordinates(<<"ne", moves::binary>>, coordinates), do: get_coordinates(moves, ["ne" | coordinates])
  defp get_coordinates(<<"nw", moves::binary>>, coordinates), do: get_coordinates(moves, ["nw" | coordinates])
  defp get_coordinates(<<"w", moves::binary>>, coordinates), do: get_coordinates(moves, ["w" | coordinates])
  defp get_coordinates(<<"e", moves::binary>>, coordinates), do: get_coordinates(moves, ["e" | coordinates])
end
