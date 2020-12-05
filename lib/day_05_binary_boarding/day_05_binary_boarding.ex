defmodule AdventOfCode.Day05BinaryBoarding do
  @doc """
  ## Examples
    iex(10)> ["BFFFBBFRRR", "FFFBBBFRRR", "BBFFBBFRLL"] |> AdventOfCode.Day05BinaryBoarding.resolve_highest_seat()
    820
  """
  def resolve_highest_seat(seat_codes) do
    seat_codes
    |> Stream.map(&resolve_seat_id/1)
    |> Enum.max()
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
