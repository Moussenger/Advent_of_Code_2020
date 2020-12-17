defmodule AdventOfCode.Day16TicketTranslation do
  @parts_separator "\n\n"
  @line_separator "\n"
  @name_separator ":"
  @your_ticket_separator "your ticket:\n"
  @nearby_tickets_separator "nearby tickets:\n"
  @name_separator ":"
  @values_separator ","
  @range_separator "-"
  @ticket_value_options_separator "or"
  @departure "departure"

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day16TicketTranslation
    iex> data = "class: 1-3 or 5-7\nrow: 6-11 or 33-44\nseat: 13-40 or 45-50\n\nyour ticket:\n7,1,14\n\nnearby tickets:\n7,3,47\n40,4,50\n55,2,20\n38,6,12"
    iex> data |> calc_ticket_scanning_error_rate()
    71
  """
  def calc_ticket_scanning_error_rate(tickets_data) do
    tickets_data
    |> parse_data()
    |> get_tickets_scanning_error()
  end

  @doc ~S"""
    ## Examples
    iex> import AdventOfCode.Day16TicketTranslation
    iex> data = "departure class: 0-1 or 4-19\nrow: 0-5 or 8-19\ndeparture seat: 0-13 or 16-19\n\nyour ticket:\n11,12,13\n\nnearby tickets:\n3,9,18\n15,1,5\n5,14,9"
    iex> data |> calc_values_for_departure()
    156
  """
  def calc_values_for_departure(tickets_data) do
    tickets_data
    |> parse_data()
    |> get_values_for_departure()
  end

  defp get_tickets_scanning_error({fields_values, _, nearby_tickets}) do
    flat_fields_values = flat_fields_values(fields_values)

    nearby_tickets
    |> Enum.flat_map(& &1)
    |> Stream.filter(&(not (&1 in flat_fields_values)))
    |> Enum.sum()
  end

  defp get_values_for_departure({fields_values, my_ticket, nearby_tickets}) do
    flat_fields_values = flat_fields_values(fields_values)
    nearby_tickets = filter_valid_nearby_tickets(nearby_tickets, flat_fields_values)

    nearby_tickets_values = Enum.zip(nearby_tickets) |> Enum.map(&Tuple.to_list/1)

    nearby_tickets_values
    |> Stream.map(&get_fields_valid_for_values(&1, fields_values))
    |> Stream.with_index()
    |> Enum.sort_by(fn {fields, _position} -> length(fields) end)
    |> reduce_fields([], [])
    |> Stream.filter(fn {name, _position} -> String.starts_with?(name, @departure) end)
    |> Stream.map(fn {_name, position} -> position end)
    |> Stream.map(&Enum.at(my_ticket, &1))
    |> Enum.reduce(1, &(&1 * &2))
  end

  defp filter_valid_nearby_tickets(nearby_tickets, valid_values) do
    nearby_tickets
    |> Enum.filter(&is_ticket_valid?(&1, valid_values))
  end

  defp is_ticket_valid?(ticket, valid_values), do: Enum.find(ticket, &(not (&1 in valid_values))) == nil

  defp get_fields_valid_for_values(values, fields_values) do
    fields_values
    |> Stream.filter(fn {_name, field_values} -> Enum.all?(values, &(&1 in field_values)) end)
    |> Enum.map(fn {name, _field_values} -> name end)
  end

  defp reduce_fields([], reduced, _used), do: reduced

  defp reduce_fields([{fields, position} | next_fields], reduced, used) do
    [field | _] = fields -- used

    reduce_fields(next_fields, [{field, position} | reduced], [field | used])
  end

  defp parse_data(tickets_data) do
    {fields_data, my_ticket, nearby_tickets} =
      tickets_data
      |> String.split(@parts_separator)
      |> List.to_tuple()

    {parse_fields_data(fields_data), parse_my_ticket(my_ticket), parse_nearby_tickets(nearby_tickets)}
  end

  defp parse_fields_data(fields_data) do
    fields_data
    |> String.split(@line_separator)
    |> Stream.map(&String.split(&1, @name_separator))
    |> Stream.map(&List.to_tuple/1)
    |> Stream.map(fn {name, values} -> {name, String.trim(values)} end)
    |> Stream.map(fn {name, values} -> {name, String.split(values, @ticket_value_options_separator)} end)
    |> Stream.map(fn {name, values} -> {name, Enum.map(values, fn value -> String.trim(value) end)} end)
    |> Stream.map(fn {name, values} -> {name, Enum.map(values, fn value -> to_range(value) end)} end)
    |> Enum.map(fn {name, values} -> {name, ranges_to_list(values)} end)
  end

  defp parse_my_ticket(my_ticket) do
    my_ticket
    |> String.split(@your_ticket_separator)
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.flat_map(&String.split(&1, @values_separator))
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_nearby_tickets(nearby_tickets) do
    nearby_tickets
    |> String.split(@nearby_tickets_separator)
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.flat_map(&String.split(&1, @line_separator))
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.map(&String.split(&1, @values_separator))
    |> Enum.map(&Enum.map(&1, fn value -> String.to_integer(value) end))
  end

  defp to_range(range_string) do
    {first, last} = range_string |> String.split(@range_separator) |> Enum.map(&String.to_integer/1) |> List.to_tuple()

    first..last
  end

  defp ranges_to_list(ranges) do
    ranges
    |> Enum.reduce(MapSet.new(), &Enum.into(&1, &2))
    |> MapSet.to_list()
    |> Enum.sort()
  end

  defp flat_fields_values(fields_values) do
    fields_values
    |> Stream.map(fn {_name, values} -> values end)
    |> Enum.reduce(MapSet.new(), &Enum.into(&1, &2))
    |> MapSet.to_list()
    |> Enum.sort()
  end
end
