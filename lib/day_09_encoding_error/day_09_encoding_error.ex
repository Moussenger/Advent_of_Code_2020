defmodule AdventOfCode.Day09EncodingError do
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day09EncodingError
    iex> data = "35 20 15 25 47 40 62 55 65 95 102 117 150 182 127 219 299 277 309 576"
    iex> data |> find_xmas_weakness(5)
    {:invalid_protocol, 127}
  """
  def find_xmas_weakness(codes, preamble_size) do
    codes
    |> parse_codes()
    |> resolve_xmas_sequence(preamble_size)
  end

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day09EncodingError
    iex> data = "35 20 15 25 47 40 62 55 65 95 102 117 150 182 127 219 299 277 309 576"
    iex> data |> break_xmas_weakness(127)
    62
  """
  def break_xmas_weakness(codes, weakness_value) do
    case codes |> parse_codes |> get_weakness_sum(weakness_value, 0, 1) do
      {:break, sum} -> sum
      error -> error
    end
  end

  defp parse_codes(codes) do
    codes
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp resolve_xmas_sequence(codes, preamble_size) when length(codes) < preamble_size, do: :valid_protocol

  defp resolve_xmas_sequence(codes, preamble_size) do
    preamble = Enum.take(codes, preamble_size)
    code = Enum.at(codes, preamble_size)

    case is_valid_code(code, preamble, preamble_size) do
      true -> resolve_xmas_sequence(Enum.drop(codes, 1), preamble_size)
      _ -> {:invalid_protocol, code}
    end
  end

  defp is_valid_code(code, preamble, preamble_size) do
    valid_combinations =
      for i <- 1..(preamble_size - 1),
          j <- 0..(i - 1),
          v1 = Enum.at(preamble, i),
          v2 = Enum.at(preamble, j),
          v1 + v2 == code,
          do: {v1, v2}

    length(valid_combinations) > 0
  end

  defp get_weakness_sum(codes, _weakness, _ini_pos, end_pos) when end_pos > length(codes), do: {:error, :no_weakness}

  defp get_weakness_sum(codes, weakness_value, ini_pos, end_pos) do
    range = Enum.slice(codes, ini_pos..end_pos)
    sum = range |> Enum.sum()

    cond do
      sum == weakness_value -> {:break, range |> smallest_and_largest |> Tuple.to_list() |> Enum.sum()}
      sum > weakness_value -> get_weakness_sum(codes, weakness_value, ini_pos + 1, ini_pos + 2)
      true -> get_weakness_sum(codes, weakness_value, ini_pos, end_pos + 1)
    end
  end

  defp smallest_and_largest(codes) do
    codes = Enum.sort(codes)

    {Enum.at(codes, 0), Enum.at(codes, length(codes) - 1)}
  end
end
