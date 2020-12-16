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

  defp get_tickets_scanning_error({fields_values, _, nearby_tickets}) do
    fields_values =
      fields_values
      |> Enum.reduce(MapSet.new(), &Enum.into(&1, &2))
      |> MapSet.to_list()
      |> Enum.sort()

    nearby_tickets
    |> Enum.flat_map(& &1)
    |> Stream.filter(&(not (&1 in fields_values)))
    |> Enum.sum()
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
    |> Stream.map(fn {_name, values} -> String.trim(values) end)
    |> Stream.map(&String.split(&1, @ticket_value_options_separator))
    |> Stream.map(&Enum.map(&1, fn value -> String.trim(value) end))
    |> Stream.map(&Enum.map(&1, fn value -> to_range(value) end))
    |> Enum.map(&ranges_to_list/1)
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
end
