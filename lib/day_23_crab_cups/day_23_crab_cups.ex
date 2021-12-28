defmodule AdventOfCode.Day23CrabCups do

  # import AdventOfCode.Day23CrabCups
  # file = "lib/day_23_crab_cups/input.txt" |> File.read!()
  def get_cups_from_1(data, moves) do
    data
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> move(0, moves)
    |> rotate_until(8, 1)
    |> List.delete(1)
    |> Enum.join()
  end

  defp move(cups, _position, 0), do: cups
  defp move(cups, position, moves) do
    size = length(cups)
    selected = Enum.at(cups, position)
    init_slice_position = rem(position + 1, size)
    {cups, sliced, first} = slice(cups, init_slice_position, 3, (if init_slice_position == 0, do: 3, else: 0), [])
    next_position = rem(position+1, size)
    next_selected = Enum.at(cups, rem(position + 1 - first, length(cups)))
    destination = destination(cups, selected - 1)
    cups = insert_slice(cups, destination, sliced)
    move(rotate_until(cups, next_position, next_selected), rem(position + 1, size), moves- 1)
  end

  defp rotate_until([cup | next_cups] = cups, index, value) do
    case Enum.at(cups, index) do
      ^value -> cups
      _ -> rotate_until(next_cups ++ [cup], index, value)
    end
  end

  defp insert_slice(cups, _position, []), do: cups
  defp insert_slice(cups, position, [slice | sliced]) do
    cups = List.insert_at(cups, position, slice)
    insert_slice(cups, rem(position + 1, length(cups)+1), sliced)
  end

  defp destination(cups, 0), do: destination(cups, 9)
  defp destination(cups, selected) do
    case Enum.find_index(cups, &(&1 == selected)) do
      nil -> destination(cups, selected - 1)
      index -> rem(index + 1, length(cups) + 1)
    end
  end

  defp slice(cups, _position, 0, first, sliced), do: {cups, Enum.reverse(sliced), first}
  defp slice(cups, position, count, first, sliced) do
    cup = Enum.at(cups, position)
    cups = List.delete(cups, cup)
    size = length(cups)

    case position == size do
      true -> slice(cups, 0, count - 1, count-1, [cup | sliced])
      false -> slice(cups, position, count - 1, first, [cup | sliced])
    end
  end
end
