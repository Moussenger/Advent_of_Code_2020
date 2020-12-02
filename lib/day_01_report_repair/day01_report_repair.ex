defmodule AdventOfCode.Day01ReportRepair do
  @doc """

  Examples:
    iex> AdventOfCode.Day01ReportRepair.get_mult_with_sum([1721, 979, 366, 299, 675, 1456], 2020, 2)
    [{2020, 514579}]

    iex> AdventOfCode.Day01ReportRepair.get_mult_with_sum([1721, 979, 366, 299, 675, 1456], 2020, 3)
    [{2020, 241861950}]
  """
  @spec get_mult_with_sum([integer], integer, integer) :: [{integer, integer, integer, integer}]
  def get_mult_with_sum(list, sum, size) do
    combinations(size, list)
    |> Enum.map(fn numbers -> {Enum.sum(numbers), Enum.reduce(numbers, &(&1 * &2))} end)
    |> Enum.filter(fn {numbers_sum, _} -> numbers_sum == sum end)
  end

  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(size, [h | t]) do
    for(item <- combinations(size - 1, t), do: [h | item]) ++ combinations(size, t)
  end
end
