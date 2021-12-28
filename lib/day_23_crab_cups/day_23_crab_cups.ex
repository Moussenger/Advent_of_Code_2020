defmodule AdventOfCode.Day23CrabCups do

  # import AdventOfCode.Day23CrabCups
  # file = "lib/day_23_crab_cups/input.txt" |> File.read!()
  def get_cups_from_1(data, moves) do
    cups = data
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> generate_map()
    |> (fn {cups, first} -> move(cups, first, 9, moves) end).()

    cups
    |> list_from_1(Map.get(cups, 1), [1])
    |> List.delete(1)
    |> Enum.join()
  end

  def get_cups_from_1_until_1_million(data, moves) do
    cups = data
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.concat(10..1_000_000 |> Enum.to_list())
    |> generate_map()
    |> (fn {cups, first} -> move(cups, first, 1_000_000, moves) end).()

    cups
    |> list_from_1(Map.get(cups, 1), [1])
    |> List.delete(1)
    |> Enum.take(2)
    |> Enum.reduce(1, fn cup, result -> cup * result end)
  end

  defp generate_map(cups) do
    first = Enum.at(cups, 0)

    cups = (cups ++ [first])
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.into(%{})

    {cups, first}
  end

  defp list_from_1(_cups, 1, list), do: Enum.reverse(list)
  defp list_from_1(cups, next, list) do
    list_from_1(cups, Map.get(cups, next),  [next | list])
  end

  defp move(cups, _position, _max, 0), do: cups
  defp move(cups, position, max, moves) do
    first = Map.get(cups, position)
    second = Map.get(cups, first)
    third = Map.get(cups, second)

    next_position = Map.get(cups, third)
    cups = Map.drop(cups, [first, second, third])
    cups = Map.put(cups, position, next_position)

    position_to_insert = get_position_to_insert(cups, position - 1, max)
    old_pointer = Map.get(cups, position_to_insert)

    cups = Map.put(cups, position_to_insert, first)
    cups = Map.put(cups, first, second)
    cups = Map.put(cups, second, third)
    cups = Map.put(cups, third, old_pointer)

    move(cups, next_position, max, moves - 1)
  end


  defp get_position_to_insert(cups, 0, max), do: get_position_to_insert(cups, max, max)
  defp get_position_to_insert(cups, position, max) do
    case Map.get(cups, position) do
      nil -> get_position_to_insert(cups, position - 1, max)
      _ -> position
    end
  end
end
