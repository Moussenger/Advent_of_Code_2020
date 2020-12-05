defmodule AdventOfCode.Day05BinaryBoarding do
  @doc """
  ## Examples
    iex> ["BFFFBBFRRR", "FFFBBBFRRR", "BBFFBBFRLL"] |> AdventOfCode.Day05BinaryBoarding.resolve_highest_seat()
    820
  """
  def resolve_highest_seat(seat_codes) do
    seat_codes
    |> resolve_seats_ids()
    |> Enum.max()
  end

  @doc """
  ## Examples
    iex> import AdventOfCode.Day05BinaryBoarding
    iex> ["FFFFFFFLLR", "FFFFFFFLRL", "FFFFFFFRLL"] |> get_free_seat()
    [{3, false}]
  """
  def get_free_seat(seat_codes) do
    seat_ids = resolve_seats_ids(seat_codes)

    Enum.min(seat_ids)..Enum.max(seat_ids)
    |> Stream.map(&{&1, &1 in seat_ids})
    |> Enum.filter(fn {_, presence} -> !presence end)
  end

  defp resolve_seats_ids(seat_codes) do
    seat_codes
    |> Enum.map(&resolve_seat_id/1)
  end

  defp resolve_seat_id(<<row::binary-size(7), column::bitstring>>) do
    row = string_to_bin(row, "F", "B")
    column = string_to_bin(column, "L", "R")

    row * 8 + column
  end

  defp string_to_bin(string, zero_value, one_value) do
    string
    |> String.replace(zero_value, "0")
    |> String.replace(one_value, "1")
    |> String.to_integer(2)
  end
end
