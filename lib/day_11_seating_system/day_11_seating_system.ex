defmodule AdventOfCode.Day11SeatingSystem do
  @floor "."
  @empty_seat "L"
  @occupied_seat "#"
  @adjacency_fields [{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1}]

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day11SeatingSystem
    iex> data = "L.LL.LL.LL LLLLLLL.LL L.L.L..L.. LLLL.LL.LL L.LL.LL.LL L.LLLLL.LL ..L.L..... LLLLLLLLLL L.LLLLLL.L L.LLLLL.LL"
    iex> data |> resolve_seats_occupied(4, :closer)
    37

    iex> import AdventOfCode.Day11SeatingSystem
    iex> data = "L.LL.LL.LL LLLLLLL.LL L.L.L..L.. LLLL.LL.LL L.LL.LL.LL L.LLLLL.LL ..L.L..... LLLLLLLLLL L.LLLLLL.L L.LLLLL.LL"
    iex> data |> resolve_seats_occupied(5, :first_seen)
    26
  """
  def resolve_seats_occupied(seats_layout, adjacency_factor, policy) do
    seats_layout
    |> parse_seats_layout()
    |> calculate_seats_occupied(adjacency_factor, policy)
  end

  defp parse_seats_layout(seats_layout) do
    rows =
      seats_layout
      |> String.split()
      |> Enum.map(&String.replace(&1, "\n", ""))

    {Enum.count(rows), String.length(Enum.at(rows, 0)), Enum.join(rows) |> String.graphemes()}
  end

  defp calculate_seats_occupied({row_count, column_count, seats_layout}, adjacency_factor, policy) do
    occupied_seats =
      calculate_occupied_by_adjacency_seats(seats_layout, seats_layout, [], 0, row_count, column_count, policy)

    new_seats = go_to_next_seat_round(seats_layout, [], occupied_seats, adjacency_factor, 0)

    cond do
      new_seats == seats_layout -> new_seats |> Stream.filter(&(&1 == @occupied_seat)) |> Enum.count()
      true -> calculate_seats_occupied({row_count, column_count, new_seats}, adjacency_factor, policy)
    end
  end

  defp go_to_next_seat_round([], new_seats, _occupied_seats, _adjacency_factor, _position) do
    Enum.reverse(new_seats)
  end

  defp go_to_next_seat_round([@floor | seats], new_seats, [_ | occupied_seats], factor, position) do
    go_to_next_seat_round(seats, [@floor | new_seats], occupied_seats, factor, position + 1)
  end

  defp go_to_next_seat_round([seat | seats], new_seats, [occupied | occupied_seats], adjacency_factor, position) do
    new_seats = [calc_new_seat_state(seat, occupied, adjacency_factor) | new_seats]
    go_to_next_seat_round(seats, new_seats, occupied_seats, adjacency_factor, position + 1)
  end

  defp calc_new_seat_state(@occupied_seat, occupied, factor) when occupied >= factor, do: @empty_seat
  defp calc_new_seat_state(@empty_seat, occupied, _factor) when occupied == 0, do: @occupied_seat
  defp calc_new_seat_state(seat, _occupied, _factor), do: seat

  defp calculate_occupied_by_adjacency_seats([], _layout, adjacency_seats, _position, _r, _c_count, _policy) do
    Enum.reverse(adjacency_seats)
  end

  defp calculate_occupied_by_adjacency_seats([@floor | seats], layout, adjacency_seats, pos, r_count, c_count, policy) do
    calculate_occupied_by_adjacency_seats(seats, layout, [0 | adjacency_seats], pos + 1, r_count, c_count, policy)
  end

  defp calculate_occupied_by_adjacency_seats([_ | seats], layout, adjacency_seats, pos, row_count, column_count, policy) do
    occupied =
      @adjacency_fields
      |> Stream.map(&get_adjacent_seat_from(&1, pos, layout, row_count, column_count, policy))
      |> Stream.filter(&(&1 == @occupied_seat))
      |> Enum.count()

    adjacency_seats = [occupied | adjacency_seats]

    calculate_occupied_by_adjacency_seats(seats, layout, adjacency_seats, pos + 1, row_count, column_count, policy)
  end

  defp get_adjacent_seat_from(delta, position, layout, row_count, column_count, policy) do
    coordinate = position_to_coordinate_with_delta(position, delta, column_count)
    position = coordinate_to_position(coordinate, column_count)

    cond do
      is_coordinate_valid(coordinate, row_count, column_count) ->
        get_first_seen_from(delta, coordinate, layout, Enum.at(layout, position), row_count, column_count, policy)

      true ->
        nil
    end
  end

  defp get_first_seen_from(delta, coordinate, layout, @floor, r_count, c_count, :first_seen) do
    position = coordinate_to_position(coordinate, c_count)
    get_adjacent_seat_from(delta, position, layout, r_count, c_count, :first_seen)
  end

  defp get_first_seen_from(_delta, _coordinate, _layout, value, _r_count, _c_count, _policy), do: value

  def is_coordinate_valid({row, column}, row_count, column_count) do
    cond do
      not (row in 0..(row_count - 1)) -> false
      not (column in 0..(column_count - 1)) -> false
      true -> true
    end
  end

  def position_to_coordinate(position, column_count), do: {div(position, column_count), rem(position, column_count)}

  def position_to_coordinate_with_delta(position, {row_delta, column_delta}, column_count) do
    {div(position, column_count) + row_delta, rem(position, column_count) + column_delta}
  end

  def coordinate_to_position({row, column}, column_count), do: row * column_count + column
end
