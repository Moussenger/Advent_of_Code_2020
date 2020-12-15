defmodule AdventOfCode.Day15RambunctiousRecitation do
  @separator ","

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day15RambunctiousRecitation
    iex> data = ["0,3,6","1,3,2","2,1,3","1,2,3","2,3,1","3,2,1","3,1,2"]
    iex> data |> Enum.map(&get_nth_spoken(&1, 2020))
    [436, 1, 10, 27, 78, 438, 1836]
  """
  def get_nth_spoken(initial, nth) do
    numbers =
      initial
      |> String.split(@separator)
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index(1)

    last_value = List.last(numbers)
    olds_map = Enum.into(numbers, %{})
    resolve_nth(last_value, olds_map, nth - Enum.count(numbers))
  end

  defp resolve_nth({last_value, _last_index}, _olds_map, 0), do: last_value

  defp resolve_nth({last_value, last_index}, olds_map, nth) do
    repeated = Map.get(olds_map, last_value)
    olds_map = Map.put(olds_map, last_value, last_index)
    new_index = last_index + 1

    new_value =
      case repeated do
        nil -> {0, new_index}
        old_index -> {last_index - old_index, new_index}
      end

    resolve_nth(new_value, olds_map, nth - 1)
  end
end
