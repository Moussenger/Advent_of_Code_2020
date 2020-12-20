defmodule AdventOfCode.Day18OperationOrder do
  @old_mult "*"
  @new_mult "~>"

  @old_sum "+"
  @new_sum "<~"

  # import AdventOfCode.Day18OperationOrder
  # data = "2 * 3 + (4 * 5)\n5 + (8 * 3 + 9 + 3 * 4 * 3)\n5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))\n((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
  # data |> sum_all_operations()
  # file = "lib/day_18_operation_order/input.txt" |> File.read!()
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day18OperationOrder
    iex> data = "2 * 3 + (4 * 5)\n5 + (8 * 3 + 9 + 3 * 4 * 3)\n5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))\n((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2"
    iex> data |> sum_all_operations()
    26335
  """
  def sum_all_operations(operations) do
    operations
    |> parse_operations()
    |> Stream.map(&Code.eval_string("import AdventOfCode.Day18OperationOrder;" <> &1))
    |> Stream.map(fn {res, _} -> res end)
    |> Stream.filter(&is_integer/1)
    |> Enum.sum()
  end

  defp parse_operations(operations) do
    operations
    |> String.replace(@old_mult, @new_mult)
    |> String.replace(@old_sum, @new_sum)
    |> String.split("\n")
  end

  def a <~ b, do: a + b
  def a ~> b, do: a * b
end
