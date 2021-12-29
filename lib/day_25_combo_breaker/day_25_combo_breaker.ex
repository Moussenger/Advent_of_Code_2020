defmodule AdventOfCode.Day25ComboBreaker do
  @reminder 20201227

  # import AdventOfCode.Day25ComboBreaker
  # file = "lib/day_25_combo_breaker/input.txt" |> File.read!()
  def reverse_public_keys(data) do
    {{card_public_key, _card_subject, card_loop_size}, {door_public_key, _door_subject, door_loop_size}} = data
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&match_loop_size/1)
    |> List.to_tuple()

    {generate_encryption_key(card_public_key, door_loop_size), generate_encryption_key(door_public_key, card_loop_size)}
  end

  defp match_loop_size(result) do
    match_loop_size(result, 7, 1, MapSet.new(), 0)
  end

  defp match_loop_size(result, subject, result, _past, iteration), do: {result, subject, iteration}
  defp match_loop_size(result, subject, value, past, iteration) do
    next = rem(value * subject, @reminder)
    case MapSet.member?(past, next) do
      true -> :invalid_subject
      false ->
        MapSet.put(past, next)
        match_loop_size(result, subject, next, past, iteration + 1)
    end
  end

  def generate_encryption_key(public_key, iterations) do
    generate_encryption_key(public_key, 1, iterations)
  end

  def generate_encryption_key(_encription_key, value, 0), do: value
  def generate_encryption_key(encription_key, value, iterations) do
    generate_encryption_key(encription_key, rem(encription_key * value, @reminder), iterations - 1)
  end
end
