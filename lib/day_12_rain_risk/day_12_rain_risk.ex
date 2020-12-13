defmodule AdventOfCode.Day12RainRisk do
  @north "N"
  @west "W"
  @south "S"
  @east "E"
  @left "L"
  @right "R"
  @forward "F"

  @vertical [@north, @south]
  @horizontal [@east, @west]

  @turn [@left, @right]

  @positive [@north, @east]
  @negative [@south, @west]

  @points [@north, @east, @south, @west]

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day12RainRisk
    iex> data = "F10 N3 F7 R90 F11"
    iex> data |> resolve_manhattan_distance()
    25
  """
  def resolve_manhattan_distance(instructions) do
    instructions
    |> parse_instructions()
    |> run_instructions(@east, {0, 0})
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split()
    |> Enum.map(fn <<instruction::binary-size(1)>> <> value -> {instruction, String.to_integer(value)} end)
  end

  defp run_instructions([], _direction, {x, y}), do: abs(x) + abs(y)

  defp run_instructions([{@forward, value} | instructions], direction, {x, y}) when direction in @vertical do
    run_instructions(instructions, direction, {x, y + value_for_direction(value, direction)})
  end

  defp run_instructions([{@forward, value} | instructions], direction, {x, y}) when direction in @horizontal do
    run_instructions(instructions, direction, {x + value_for_direction(value, direction), y})
  end

  defp run_instructions([{point, value} | instructions], direction, {x, y}) when point in @vertical do
    run_instructions(instructions, direction, {x, y + value_for_direction(value, point)})
  end

  defp run_instructions([{point, value} | instructions], direction, {x, y}) when point in @horizontal do
    run_instructions(instructions, direction, {x + value_for_direction(value, point), y})
  end

  defp run_instructions([{turn, value} | instructions], direction, {x, y}) when turn in @turn do
    run_instructions(instructions, turn_direction(turn, direction, value), {x, y})
  end

  defp value_for_direction(value, direction) when direction in @negative, do: -value
  defp value_for_direction(value, direction) when direction in @positive, do: +value

  defp turn_direction(@right, direction, degrees) do
    move = div(rem(degrees, 360), 90)
    Enum.at(@points, rem((@points |> Enum.find_index(&(&1 == direction))) + move, length(@points)))
  end

  defp turn_direction(@left, direction, degrees) do
    move = div(rem(degrees, 360), 90)
    Enum.at(@points, rem((@points |> Enum.find_index(&(&1 == direction))) - move, length(@points)))
  end
end
