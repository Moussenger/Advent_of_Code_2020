defmodule AdventOfCode.Day03TobogganTrajectory do
  @tree "#"

  @doc """
  ## Examples
      iex> import AdventOfCode.Day03TobogganTrajectory
      iex> slope = "..##....... #...#...#.. .#....#..#. ..#.#...#.# .#...##..#. ..#.##..... .#.#.#....# .#........# #.##...#... #...##....# .#..#...#.#"
      iex> get_trees_from_slope_with_moves(slope, [{1, 1}, {3, 1}, {5, 1}, {7, 1}, {1, 2}])
      336

  """
  def get_trees_from_slope_with_moves(slope, moves) do
    moves
    |> Enum.map(fn {right, down} -> get_trees_from_slope(slope, right, down) end)
    |> Enum.reduce(&(&1 * &2))
  end

  @doc """
  ## Examples

      iex> import AdventOfCode.Day03TobogganTrajectory
      iex> slope = "..##....... #...#...#.. .#....#..#. ..#.#...#.# .#...##..#. ..#.##..... .#.#.#....# .#........# #.##...#... #...##....# .#..#...#.#"
      iex> get_trees_from_slope(slope, 3, 1)
      7

  """
  def get_trees_from_slope(slope, slope_right, slope_down) do
    slope = parse_slope(slope)
    width = slope |> Enum.at(1) |> Enum.count()

    traverse_slope(slope, width, slope_right, slope_down, 0, 0, length(slope) - 1, 0)
  end

  defp parse_slope(slope) do
    slope
    |> String.split()
    |> Enum.map(&String.graphemes/1)
  end

  defp traverse_slope(_slope, _width, _slope_right, _slope_down, _right, high, high, trees), do: trees

  defp traverse_slope(slope, width, slope_right, slope_down, right, down, high, trees) do
    current_right = rem(right + slope_right, width)
    current_down = down + slope_down
    current_position = slope |> Enum.at(current_down) |> Enum.at(current_right)

    trees =
      case current_position do
        @tree -> trees + 1
        _ -> trees
      end

    traverse_slope(slope, width, slope_right, slope_down, current_right, current_down, high, trees)
  end
end
