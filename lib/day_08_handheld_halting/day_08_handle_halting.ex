defmodule AdventOfCode.Day08HandleHalting do
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day08HandleHalting
    iex> data = "nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6"
    iex> data |> run_program(&run_without_fix/1)
    {:loop, 5}

    iex> import AdventOfCode.Day08HandleHalting
    iex> data = "nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6"
    iex> data |> run_program(&run_with_fix/1)
    {:no_loop, 8}
  """
  def run_program(instructions, policy) do
    instructions
    |> parse_instructions()
    |> policy.()
  end

  def run_without_fix(instructions), do: run(instructions, Enum.at(instructions, 0), 0, [], false, 0)

  def run_with_fix(instructions), do: run_with_fix(instructions, instructions, 0)

  defp run_with_fix(original_instructions, modified_instructions, last_try) do
    case run(modified_instructions, Enum.at(modified_instructions, 0), 0, [], false, 0) do
      {:loop, _} ->
        {new_instructions, last_try} = fix_instructions(original_instructions, last_try)
        run_with_fix(original_instructions, new_instructions, last_try)

      result ->
        result
    end
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("\n")
    |> Stream.map(&(String.split(&1) |> List.to_tuple()))
    |> Stream.filter(&(length(Tuple.to_list(&1)) > 0))
    |> Enum.map(fn {instruction, arg} -> {instruction, String.to_integer(arg)} end)
  end

  defp fix_instructions(instructions, last_try) do
    {previous_instructions, next_instructions} = Enum.split(instructions, last_try)

    case do_fix_instructions(previous_instructions, next_instructions) do
      :no_fix -> fix_instructions(instructions, last_try + 1)
      new_instructions -> {new_instructions, last_try + 1}
    end
  end

  defp do_fix_instructions(previous_instructions, [{"nop", arg} | last_instructions]) do
    previous_instructions ++ [{"jmp", arg} | last_instructions]
  end

  defp do_fix_instructions(previous_instructions, [{"jmp", arg} | last_instructions]) do
    previous_instructions ++ [{"nop", arg} | last_instructions]
  end

  defp do_fix_instructions(_previous_instructions, _last_instructions), do: :no_fix

  defp run(_instructions, _next, _next_pos, _previous_pos, true, accumulator), do: {:loop, accumulator}

  defp run(instructions, {"acc", arg}, next_pos, previous_pos, _repeated, accumulator) do
    next_pos = next_pos + 1
    repeated = next_pos in previous_pos

    run(instructions, Enum.at(instructions, next_pos), next_pos, [next_pos | previous_pos], repeated, accumulator + arg)
  end

  defp run(instructions, {"jmp", arg}, next_pos, previous_pos, _repeated, accumulator) do
    next_pos = next_pos + arg
    repeated = next_pos in previous_pos

    run(instructions, Enum.at(instructions, next_pos), next_pos, [next_pos | previous_pos], repeated, accumulator)
  end

  defp run(instructions, {"nop", _arg}, next_pos, previous_pos, _repeated, accumulator) do
    next_pos = next_pos + 1
    repeated = next_pos in previous_pos

    run(instructions, Enum.at(instructions, next_pos), next_pos, [next_pos | previous_pos], repeated, accumulator)
  end

  defp run(_instructions, _instruction, _next_pos, _previous_pos, _repeated, accumulator) do
    {:no_loop, accumulator}
  end
end
