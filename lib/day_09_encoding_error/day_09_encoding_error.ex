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
    |> String.split()
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
    |> resolve_xmas_sequence(preamble_size)
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
end
