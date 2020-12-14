defmodule AdventOfCode.Day14DockingData do
  @space " "
  @empty ""
  @equals "="
  @close_bracket "]"
  @mask_length 36
  @default_mask "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  @zero "0"
  @one "1"
  @neutral "X"

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day14DockingData
    iex> data = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X\nmem[8] = 11\nmem[7] = 101\nmem[8] = 0"
    iex> data |> execute_initialization_program()
    165
  """
  def execute_initialization_program(program) do
    program
    |> parse_program()
    |> run_program(@default_mask, %{})
  end

  defp parse_program(program) do
    program
    |> String.split("\n")
    |> Stream.filter(&(String.length(&1) > 0))
    |> Stream.map(&String.replace(&1, @space, @empty))
    |> Stream.map(&(String.split(&1, @equals) |> List.to_tuple()))
    |> Stream.map(&parse_instruction/1)
    |> Enum.to_list()
  end

  defp parse_instruction({"mask", mask}), do: {:mask, mask}

  defp parse_instruction({"mem[" <> position, value}) do
    {:mem, position |> String.replace(@close_bracket, @empty) |> String.to_integer(), String.to_integer(value)}
  end

  defp run_program([], _mask, memory) do
    memory |> Map.values() |> Enum.sum()
  end

  defp run_program([{:mask, new_mask} | instructions], _mask, memory) do
    run_program(instructions, String.graphemes(new_mask), memory)
  end

  defp run_program([{:mem, position, value} | instructions], mask, memory) do
    value = value_to_mask_string(value)
    result = apply_mask(mask, value, [])
    memory = Map.put(memory, position, result)

    run_program(instructions, mask, memory)
  end

  defp apply_mask([], [], result), do: result |> Enum.reverse() |> Enum.join() |> String.to_integer(2)
  defp apply_mask([@zero | mask], [_v | value], result), do: apply_mask(mask, value, [0 | result])
  defp apply_mask([@one | mask], [_v | value], result), do: apply_mask(mask, value, [1 | result])
  defp apply_mask([@neutral | mask], [v | value], result), do: apply_mask(mask, value, [v | result])

  defp value_to_mask_string(value) do
    value |> Integer.to_string(2) |> String.pad_leading(@mask_length, @zero) |> String.graphemes()
  end
end
