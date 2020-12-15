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
    initial
    |> String.split(@separator)
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(1)
    |> Enum.reverse()
    |> resolve_nth(nth)
  end

  defp resolve_nth([{last_value, _} | _values] = numbers, nth) when length(numbers) == nth, do: last_value

  defp resolve_nth([{last_value, last_index} | values] = numbers, nth) do
    repeated = Enum.find(values, fn {value, _} -> value == last_value end)
    new_index = last_index + 1

    new_value =
      case repeated do
        nil -> {0, new_index}
        {_, old_index} -> {last_index - old_index, new_index}
      end

    resolve_nth([new_value | numbers], nth)
  end
end
