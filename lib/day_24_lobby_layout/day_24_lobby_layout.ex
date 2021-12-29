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

  defp colour(tiles), do: colour(tiles, %{})
  defp colour([], map), do: map
  defp colour([tile | tiles], map) do
    colour(tiles, Map.update(map, tile, :black, &(if &1 == :black, do: :white, else: :black)))
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
