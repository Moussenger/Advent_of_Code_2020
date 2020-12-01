defmodule Day01ReportRepair do
  @doc """

  Examples:
    iex> Day01ReportRepair.get_mult_with_sum([1721, 979, 366, 299, 675, 1456], 2020)
    [{299, 1721, 2020, 514579}]
  """
  @spec get_mult_with_sum([integer], integer) :: [{integer, integer, integer, integer}]
  def get_mult_with_sum(list, sum) do
    for(x <- list, y <- list, x != y, do: [x, y] |> Enum.sort() |> List.to_tuple())
    |> Enum.uniq()
    |> Enum.map(fn {x, y} -> {x, y, x + y, x * y} end)
    |> Enum.filter(fn {_, _, result, _} -> result == sum end)
  end
end
