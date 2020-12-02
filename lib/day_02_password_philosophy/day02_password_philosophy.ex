defmodule AdventOfCode.Day02PasswordPhilosophy do
  @moduledoc """
  ## Examples

      iex> import AdventOfCode.Day02PasswordPhilosophy
      iex> validate_passwords(["1-3 a: abcde","1-3 b: cdefg", "2-9 c: ccccccccc"], &is_password_valid_by_count?/1)
      2

      iex> import AdventOfCode.Day02PasswordPhilosophy
      iex> validate_passwords(["1-3 a: abcde","1-3 b: cdefg", "2-9 c: ccccccccc"], &is_password_valid_by_position?/1)
      1
  """

  def validate_passwords(passwords_list, policy) do
    passwords_list
    |> Stream.map(&parse_password/1)
    |> Stream.map(policy)
    |> Stream.filter(& &1)
    |> Enum.count()
  end

  def is_password_valid_by_count?({password, char, range}) do
    char_count = password |> String.graphemes() |> Stream.filter(&(&1 == char)) |> Enum.count()

    char_count in range
  end

  def is_password_valid_by_position?({password, char, range}) do
    first..last = range
    chars = String.graphemes(password)
    first_char = Enum.at(chars, first - 1)
    second_char = Enum.at(chars, last - 1)

    (first_char == char or second_char == char) and first_char != second_char
  end

  defp parse_password(password) do
    {range, char, password} = password |> String.split() |> List.to_tuple()

    {range_min, range_max} =
      String.split(range, "-") |> Enum.map(&String.to_integer/1) |> List.to_tuple()

    [char | _] = char |> String.graphemes()

    {password, char, range_min..range_max}
  end
end
