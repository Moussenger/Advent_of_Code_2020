defmodule AdventOfCode.Day13ShuttleSearch do
  @unknown_ids "x"
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day13ShuttleSearch
    iex> data = "939 7,13,x,x,59,x,31,19"
    iex> data |> get_bus_id_times_minutes()
    295
  """
  def get_bus_id_times_minutes(schedule) do
    schedule
    |> parse_schedule()
    |> resolve_next_departure()
  end

  defp parse_schedule(schedule) do
    {current_timestamp, frequencies} =
      schedule
      |> String.split()
      |> List.to_tuple()

    current_timestamp = String.to_integer(current_timestamp)

    frequencies =
      frequencies
      |> String.split(",")
      |> Enum.filter(&(&1 != @unknown_ids))
      |> Enum.map(&String.to_integer/1)

    {current_timestamp, frequencies}
  end

  defp resolve_next_departure({current_timestamp, frequencies}) do
    remaining_frequencies = calc_remaining_frequencies(frequencies, current_timestamp)
    resolve_next_departure(current_timestamp, frequencies, remaining_frequencies, current_timestamp)
  end

  defp resolve_next_departure(timestamp, frequencies, remaining_frequencies, current_timestamp) do
    departure_position = remaining_frequencies |> Enum.find_index(&(&1 == 0))
    next_timestamp = current_timestamp + 1
    remaining_frequencies = calc_remaining_frequencies(frequencies, next_timestamp)

    case departure_position do
      nil -> resolve_next_departure(timestamp, frequencies, remaining_frequencies, next_timestamp)
      position -> (current_timestamp - timestamp) * Enum.at(frequencies, position)
    end
  end

  defp calc_remaining_frequencies(frequencies, timestamp), do: frequencies |> Enum.map(&rem(timestamp, &1))
end
