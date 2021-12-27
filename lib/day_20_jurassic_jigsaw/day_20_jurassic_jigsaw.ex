defmodule AdventOfCode.Day20JurassicJigsaw do

  # import AdventOfCode.Day20JurassicJigsaw
  # file = "lib/day_20_jurassic_jigsaw/input.txt" |> File.read!()
  def mount_jigsaw(data) do
    data
    |> String.split("\n\n")
    |> Enum.map(&parse_piece/1)
    |> build_jigsaw()
    |> get_corners()
  end

  defp get_corners(jigsaw) do
    jigsaw
    |> Map.values()
    |> Enum.filter(&(length(Map.keys(&1)) == 3))
    |> Enum.map(&(Map.get(&1, :tile)))
    |> Enum.map(&(Map.get(&1, :id)))
    |> Enum.reduce(&(&1*&2))
  end

  defp build_jigsaw([first | pieces]) do
    pieces_matched = %{first.id => %{tile: Enum.at(first.rotations, 0)} }
    build_jigsaw(pieces, pieces_matched)
  end

  defp build_jigsaw([], matches), do: matches
  defp build_jigsaw(pieces, matches) do
    to_match = matches |> Enum.map(fn {_, value} -> value.tile end)

    new_matches = to_match |> match_pieces(pieces) |> merge_matches(matches)
    remaining_pieces = Enum.filter(pieces, &(!Enum.any?(Map.keys(new_matches), fn match -> match == Map.get(&1, :id) end)))

    build_jigsaw(remaining_pieces, new_matches)
  end

  defp merge_matches(new_matches, old_matches) do
    keys = Map.keys(new_matches)

    Enum.reduce(keys, old_matches, &(Map.update(&2, &1, Map.get(new_matches, &1), fn match -> Map.merge(match, Map.get(new_matches, &1)) end )))
  end

  defp match_pieces(to_match, [piece|pieces]) do
    matches = match(piece, to_match, %{})

    case length(Map.keys(matches)) do
      0 -> match_pieces(to_match, pieces)
      _ -> matches
    end
  end


  defp update_matches(matches, match1, match2) do
    {tile1, _sides1} = Map.pop(match1, :tile)
    {tile2, _sides2} = Map.pop(match2, :tile)

    matches
    |> Map.update(tile1.id, match1, &(Map.merge(&1, match1)))
    |> Map.update(tile2.id, match2, &(Map.merge(&1, match2)))
  end

  defp match(_, [], matches), do: matches
  defp match(piece, [piece_to_match | pieces_to_match], matches) do
    with {match1, match2} <- match_piece(piece.rotations, piece_to_match) do
      new_matches = update_matches(matches, match1, match2)
      match(piece, pieces_to_match, new_matches)
    else
      :no_match -> match(piece, pieces_to_match, matches)
    end
  end

  defp match_piece([], _), do: :no_match
  defp match_piece([piece | orientations], piece_to_match) do
    with {_, _} = match <- match_tiles(piece, piece_to_match) do
      match
    else
      :no_match -> match_piece(orientations, piece_to_match)
    end
  end

  defp match_tiles(%{right: side} = tile1, %{left: side} = tile2), do: {%{tile: tile1, right: tile2}, %{tile: tile2, left: tile1}}
  defp match_tiles(%{left: side} = tile1, %{right: side} = tile2), do: {%{tile: tile1, left: tile2}, %{tile: tile2, right: tile1}}
  defp match_tiles(%{top: side} = tile1, %{bottom: side} = tile2), do: {%{tile: tile1, top: tile2}, %{tile: tile2, bottom: tile1}}
  defp match_tiles(%{bottom: side} = tile1, %{top: side} = tile2), do: {%{tile: tile1, bottom: tile2}, %{tile: tile2, top: tile1}}
  defp match_tiles(_, _), do: :no_match


  defp parse_piece(piece) do
    lines = String.split(piece, "\n")
    "Tile "<> id = List.first(lines) |> String.replace(":", "")

    piece = lines |> List.delete_at(0) |> Enum.map(&String.graphemes/1)

    %{
      id: String.to_integer(id),
      rotations: resolve_flippings_and_rotations(id, piece)
    }
  end

  defp piece_data(id, piece) do
    zipped = piece |> Enum.zip_with(& &1) |> Enum.map(&Enum.join/1)
    piece = piece |> Enum.map(&Enum.join/1)

    %{
      id: String.to_integer(id),
      tile: piece,
      top: List.first(piece),
      bottom: List.last(piece),
      left: List.first(zipped),
      right: List.last(zipped),
    }
  end

  defp resolve_flippings_and_rotations(id, tile) do
    resolve_rotations(tile)
    |> resolve_flippings_and_rotations(id, [])
  end

  defp resolve_flippings_and_rotations([], _id, result), do: result

  defp resolve_flippings_and_rotations([tile | others], id, result) do
    flippings = tile |> resolve_flippings() |> Enum.map(&(piece_data(id, &1)))
    resolve_flippings_and_rotations(others, id, result ++ flippings)
  end

  defp resolve_rotations(tile) do
    rotation1 = tile |> Enum.zip_with(& &1) |> Enum.map(&Enum.reverse/1)
    rotation2 = rotation1 |> Enum.zip_with(& &1) |> Enum.map(&Enum.reverse/1)
    rotation3 = rotation2 |> Enum.zip_with(& &1) |> Enum.map(&Enum.reverse/1)

    [tile, rotation1, rotation2, rotation3]
  end

  defp resolve_flippings(tile) do
    [
      tile,
      tile |> Enum.reverse(),
    ]
  end

end
