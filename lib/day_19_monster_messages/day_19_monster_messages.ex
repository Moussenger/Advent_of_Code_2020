defmodule AdventOfCode.Day19MonsterMessages do
  @a "a"
  @b "b"

  # data = "0: 6 7\n1: 2 3 | 3 2\n2: 4 4 | 5 5\n3: 4 5 | 5 4\n4: \"a\"\n5: \"b\"\n6: 4\n7: 1 5\n\nababbb\nbababa\nabbbab\naaabbb\naaaabbb\n"
  # import AdventOfCode.Day19MonsterMessages
  # file = "lib/day_19_monster_messages/input2.txt" |> File.read!()
  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day19MonsterMessages
    iex> data = "0: 4 1 5\n1: 2 3 | 3 2\n2: 4 4 | 5 5\n3: 4 5 | 5 4\n4: \"a\"\n5: \"b\"\n\nababbb\nbababa\nabbbab\naaabbb\naaaabbb\n"
    iex> data |> count_valid_messages()
    2
  """
  def count_valid_messages(data) do
    {rules, messages} = data |> String.split("\n\n") |> List.to_tuple()

    {:ok, regex} =
      rules
      |> parse_rules()
      |> Enum.map(&sanitize_bifurcations/1)
      |> reduce_rules()
      |> rules_to_regex("^")
      |> Kernel.<>("$")
      |> :re2.compile

    messages
    |> String.split()
    |> Stream.filter(&is_tuple(:re2.match(&1, regex)))
    |> Enum.count()

  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Stream.map(&parse_rule/1)
    |> Enum.map(fn {id, rule} -> {String.to_integer(id), rule} end)
    |> Enum.sort_by(fn {id, _rule} -> id end)
    |> Enum.map(&sanitize_rule/1)
    |> Enum.map(&parse_rule_items/1)
    |> Stream.map(fn item -> if is_binary(Enum.at(item, 0)), do: Enum.at(item, 0), else: item end)
    |> Enum.to_list()
  end

  defp parse_rule(rule) do
    rule
    |> String.split(":")
    |> Enum.map(&String.trim/1)
    |> List.to_tuple()
  end

  defp sanitize_rule({id, rule}) do
    rule = rule
    |> String.replace("\"", "")
    |> String.split("|")
    |> Enum.map(&String.trim/1)

    {id, rule}
  end

  defp parse_rule_items({id, rule}) do
    id = to_string(id)

    rule
    |> Enum.map(&String.split/1)
    |> Enum.map(fn rule -> generate_recursivity(rule, id, 15) end)
    |> simplify_rule_item()
    |> Enum.map(&parse_rule_item/1)
    |> flat_rules([])
  end

  defp flat_rules([],  rules_flatten), do: Enum.reverse(rules_flatten)
  defp flat_rules([[[_|_] |_] = nested_rules | rules], rules_flatten) when is_list(nested_rules), do: flat_rules(rules, flat_rules(nested_rules, []) ++ rules_flatten)
  defp flat_rules([rule | rules], rules_flatten), do: flat_rules(rules, [rule | rules_flatten])

  defp generate_recursivity(rule, id, iterations) do
    if(Enum.member?(rule, id)) do
      do_recursivity(rule, [], id, iterations)
    else
      rule
    end
  end

  defp do_recursivity(_rule, new_rules, _id, 0), do: new_rules
  defp do_recursivity(rule, new_rules, id, iteration) do
    new_rules = [replace_recursively(rule, rule, id, iteration) | new_rules]

    do_recursivity(rule, new_rules, id, iteration - 1)
  end

  defp replace_recursively(_, new_rule, id, 0), do: replace(new_rule, id, "") |> Enum.filter(& &1 != "")

  defp replace_recursively(rule, new_rule, id, iteration) do
    new_rule = replace(new_rule, id, rule) |> List.flatten()

    replace_recursively(rule, new_rule, id, iteration - 1)
  end

  defp replace(list, old, new) do
    list |> Enum.map(fn item -> if(item == old, do: new, else: item) end)
  end

  defp simplify_rule_item(rule_item) do
    case length(rule_item) do
      1 -> List.flatten(rule_item)
      _ -> rule_item
    end
  end

  defp parse_rule_item(item) when item == @a or item == @b, do: item
  defp parse_rule_item(item) when is_list(item), do: Enum.map(item, &parse_rule_item/1)
  defp parse_rule_item(item), do: String.to_integer(item)

  defp sanitize_bifurcations(rules) when is_list(rules) do
    if Enum.all?(rules, &is_list/1) do
      List.to_tuple(rules)
    else
      {rules}
    end
  end

  defp sanitize_bifurcations(rules), do: rules

  defp reduce_rules([rule0 | _] = rules) do
    reduce_rules(rules, reduce_rule(rules, rule0))
  end

  defp reduce_rules(rules, reduced_rule) when is_tuple(reduced_rule), do: reduce_rules(rules, Tuple.to_list(reduced_rule))

  defp reduce_rules(rules, reduced_rule) do
    new_reduced_rule =
      reduced_rule
      |> Enum.map(&reduce_rule(rules, &1))

    if(new_reduced_rule == reduced_rule) do
      reduced_rule
    else
      reduce_rules(rules, new_reduced_rule)
    end
  end

  defp reduce_rule(_rules, rule) when is_binary(rule), do: rule
  defp reduce_rule(rules, rule) when is_integer(rule), do: Enum.at(rules, rule)

  defp reduce_rule(rules, rule) when is_tuple(rule) do
    rule
    |> Tuple.to_list()
    |> Enum.map(& reduce_subrules(rules, &1))
    |> List.to_tuple()
    # {reduce_subrules(rules, elem(rule, 0)), reduce_subrules(rules, elem(rule, 1))}
  end

  defp reduce_rule(_rules, rule) when is_list(rule) and length(rule) == 1, do: Enum.at(rule, 0)

  defp reduce_rule(rules, rule) when rule == nil, do: rules

  defp reduce_rule(rules, rule) do
    Enum.map(rule, &reduce_subrules(rules, &1))
  end

  defp reduce_subrules(rules, subrule) when is_list(subrule), do: reduce_rules(rules, subrule)
  defp reduce_subrules(rules, subrule), do: reduce_rule(rules, subrule)

  defp rules_to_regex([], regex), do: regex

  defp rules_to_regex([rule | rules], regex) when is_tuple(rule) do
    regex_rules = rule |> Tuple.to_list() |> Enum.map(& rules_to_regex(&1, "")) |> Enum.join("|")
    regex = regex <> "(" <> regex_rules <> ")"

    rules_to_regex(rules, regex)
  end

  defp rules_to_regex(rule, regex) when is_tuple(rule) do
    regex_rules = rule |> Tuple.to_list() |> Enum.map(& rules_to_regex(&1, "")) |> Enum.join("|")

    regex <> "(" <> regex_rules <> ")"
  end

  defp rules_to_regex([rule | rules], regex) when is_list(rule) do
    new_regex =
      rule
      |> Stream.map(&rules_to_regex(&1, ""))
      |> Enum.join()

    rules_to_regex(rules, regex <> new_regex)
  end

  defp rules_to_regex([rule | rules], regex), do: rules_to_regex(rules, regex <> rule)
  defp rules_to_regex(nil, regex), do: regex
  defp rules_to_regex(rule, regex), do: regex <> rule
end
