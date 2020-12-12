defmodule AdventOfCode.Day11SeatingSystem do
  @floor "."
  @empty_seat "L"
  @occupied_seat "#"
  @adjacency_fields [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day11SeatingSystem
    iex> data = "L.LL.LL.LL LLLLLLL.LL L.L.L..L.. LLLL.LL.LL L.LL.LL.LL L.LLLLL.LL ..L.L..... LLLLLLLLLL L.LLLLLL.L L.LLLLL.LL"
    iex> data |> resolve_seats_occupied(4)
    37
  """
  def resolve_seats_occupied(seats_layout, adjacency_factor) do
    seats_layout
    |> parse_seats_layout()
    |> calculate_seats_occupied(adjacency_factor)
  end

  defp parse_seats_layout(seats_layout) do
    rows =
      seats_layout
      |> String.split()
      |> Enum.map(&String.replace(&1, "\n", ""))

    {Enum.count(rows), String.length(Enum.at(rows, 0)), Enum.join(rows) |> String.graphemes()}
  end

  defp calculate_seats_occupied({row_count, column_count, seats_layout}, adjacency_factor) do
    new_seats = go_to_next_seat_round(seats_layout, seats_layout, [], adjacency_factor, 0, row_count, column_count)

    cond do
      new_seats == seats_layout -> new_seats |> Stream.filter(&(&1 == @occupied_seat)) |> Enum.count()
      true -> calculate_seats_occupied({row_count, column_count, new_seats}, adjacency_factor)
    end
  end

  defp go_to_next_seat_round([], _old_seats, new_seats, _adjacency_factor, _pos, _row_count, _column_count) do
    new_seats
  end

  defp go_to_next_seat_round([@floor | seats], old, new, factor, position, row_count, column_count) do
    go_to_next_seat_round(seats, old, new ++ [@floor], factor, position + 1, row_count, column_count)
  end

  defp go_to_next_seat_round([seat | seats], old_seats, new_seats, adjacency_factor, position, row_count, column_count) do
    {row, column} = position_to_coordinate(position, column_count)

    occupied =
      @adjacency_fields
      |> Stream.map(fn {row_delta, column_delta} -> {row + row_delta, column + column_delta} end)
      |> Stream.map(fn {row, column} -> get_from_layout(old_seats, row, column, row_count, column_count) end)
      |> Stream.filter(&(&1 == @occupied_seat))
      |> Enum.count()

    new_seats = new_seats ++ [calc_new_seat_state(seat, occupied, adjacency_factor)]
    go_to_next_seat_round(seats, old_seats, new_seats, adjacency_factor, position + 1, row_count, column_count)
  end

  defp calc_new_seat_state(@occupied_seat, occupied, factor) when occupied >= factor, do: @empty_seat
  defp calc_new_seat_state(@empty_seat, occupied, _factor) when occupied == 0, do: @occupied_seat
  defp calc_new_seat_state(seat, _occupied, _factor), do: seat

  def get_from_layout(layout, row, column, row_count, column_count) do
    cond do
      not (row in 0..(row_count - 1)) -> nil
      not (column in 0..(column_count - 1)) -> nil
      true -> Enum.at(layout, row * column_count + column)
    end
  end

  def position_to_coordinate(position, column_count), do: {div(position, column_count), rem(position, column_count)}
end
