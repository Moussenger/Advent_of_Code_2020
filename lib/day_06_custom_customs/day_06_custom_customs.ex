defmodule AdventOfCode.Day06CustomCustoms do
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day06CustomCustoms
    iex> "abc\n\na\nb\nc\n\nab\nac\n\na\na\na\na\n\nb\n" |> get_unique_answers_for_groups()
    11
  """
  def get_unique_answers_for_groups(groups_answers) do
    groups_answers
    |> parse_group_answers()
    |> Stream.map(&Enum.uniq/1)
    |> Stream.map(&Enum.count/1)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day06CustomCustoms
    iex> "abc\n\na\nb\nc\n\nab\nac\n\na\na\na\na\n\nb\n" |> resolve_commons_answers
    6
  """
  def resolve_commons_answers(group_answers) do
    group_answers
    |> parse_group_answers_for_commons()
    |> Stream.map(&get_commons/1)
    |> Enum.sum()
  end

  defp parse_group_answers(group_answers) do
    group_answers
    |> String.split("\n\n")
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.graphemes/1)
  end

  defp parse_group_answers_for_commons(group_answers) do
    group_answers
    |> String.split("\n\n")
    |> Stream.map(&String.split/1)
    |> Stream.map(&Enum.map(&1, fn x -> String.graphemes(x) end))
  end

  defp get_commons([first_answer | rest_answers]) do
    rest_answers
    |> Enum.reduce(first_answer, &get_commons_for_answer/2)
    |> Enum.count()
  end

  defp get_commons_for_answer(answer, commons), do: commons -- commons -- answer
end
