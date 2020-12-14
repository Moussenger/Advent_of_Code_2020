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
    iex> data |> execute_initialization_program(:decoder)
    165

    iex> import AdventOfCode.Day14DockingData
    iex> data = "mask = 000000000000000000000000000000X1001X\nmem[42] = 100\nmask = 00000000000000000000000000000000X0XX\nmem[26] = 1"
    iex> data |> execute_initialization_program(:addresser)
    208
  """
  def execute_initialization_program(program, policy) do
    program
    |> parse_program()
    |> run_program(@default_mask, %{}, policy)
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

  defp run_program([], _mask, memory, _policy) do
    memory |> Map.values() |> Enum.sum()
  end

  defp run_program([{:mask, new_mask} | instructions], _mask, memory, policy) do
    run_program(instructions, String.graphemes(new_mask), memory, policy)
  end

  defp run_program([{:mem, position, value} | instructions], mask, memory, :decoder) do
    value = value_to_mask_string(value)
    result = apply_mask(mask, value, [])
    memory = Map.put(memory, position, result)

    run_program(instructions, mask, memory, :decoder)
  end

  defp run_program([{:mem, position, value} | instructions], mask, memory, :addresser) do
    position = value_to_mask_string(position)
    position_masked = apply_mask_for_address(mask, position, [])
    memory = get_addresses_for(position_masked) |> Enum.reduce(memory, &Map.put(&2, &1, value))

    run_program(instructions, mask, memory, :addresser)
  end

  defp get_addresses_for(position_masked) do
    get_positions_substitutions(position_masked)
    |> Stream.map(&replace_floatings(&1, position_masked, []))
    |> Stream.map(&Enum.join/1)
    |> Enum.map(&String.to_integer(&1, 2))
  end

  defp replace_floatings(_substitutions, [], result), do: result |> Enum.reverse()
  defp replace_floatings([sub | subs], [@neutral | address], res), do: replace_floatings(subs, address, [sub | res])
  defp replace_floatings(subs, [bit | address], result), do: replace_floatings(subs, address, [bit | result])

  defp apply_mask([], [], result), do: result |> Enum.reverse() |> Enum.join() |> String.to_integer(2)
  defp apply_mask([@zero | mask], [_v | value], result), do: apply_mask(mask, value, [0 | result])
  defp apply_mask([@one | mask], [_v | value], result), do: apply_mask(mask, value, [1 | result])
  defp apply_mask([@neutral | mask], [v | value], result), do: apply_mask(mask, value, [v | result])

  defp apply_mask_for_address([], [], result), do: result |> Enum.reverse()
  defp apply_mask_for_address([@zero | mask], [v | value], res), do: apply_mask_for_address(mask, value, [v | res])
  defp apply_mask_for_address([@one | mask], [_v | value], res), do: apply_mask_for_address(mask, value, [1 | res])
  defp apply_mask_for_address([@neutral | mask], [_ | value], res), do: apply_mask_for_address(mask, value, ["X" | res])

  defp value_to_mask_string(value) do
    value |> Integer.to_string(2) |> String.pad_leading(@mask_length, @zero) |> String.graphemes()
  end

  defp get_positions_substitutions(position) do
    count =
      position
      |> Stream.filter(&(&1 == @neutral))
      |> Enum.count()

    count
    |> to_range_base_2()
    |> Stream.map(&Integer.to_string(&1, 2))
    |> Stream.map(&String.pad_leading(&1, count, @zero))
    |> Enum.map(&String.graphemes/1)
  end

  defp to_range_base_2(value), do: 0..(pow_int_2(value) - 1)
  defp pow_int_2(value), do: :math.pow(2, value) |> round()
end
