defmodule AdventOfCode.Day08HandleHalting do
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day08HandleHalting
    iex> data = "nop +0\nacc +1\njmp +4\nacc +3\njmp -3\nacc -99\nacc +1\njmp -4\nacc +6"
    iex> data |> run_program
    5
  """
  def run_program(instructions) do
    instructions = instructions |> parse_instructions()

    run(instructions, Enum.at(instructions, 0), 0, [], false, 0)
  end

  defp parse_instructions(instructions) do
    instructions
    |> String.split("\n")
    |> Stream.map(&(String.split(&1) |> List.to_tuple()))
    |> Stream.filter(&(length(Tuple.to_list(&1)) > 0))
    |> Enum.map(fn {instruction, arg} -> {instruction, String.to_integer(arg)} end)
  end

  defp run(_instructions, _next, _next_pos, _previous_pos, true, accumulator), do: accumulator

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

  defp run(_instructions, _instruction, _next_pos, _previous_pos, _repeated, _accumulator) do
    System.halt(-1)
  end
end
