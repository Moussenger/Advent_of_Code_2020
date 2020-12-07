defmodule AdventOfCode.Day07HandyHaversacks do
  @input_regex ~r/^(\w+ \w+) bags contain (.*).$/
  @bags_regex ~r/,?\s?\d (\w+ \w+) bag[s]?/
  @bags_with_capacity_regex ~r/,?\s?(\d) (\w+ \w+) bag[s]?/

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day07HandyHaversacks
    iex> data = "light red bags contain 1 bright white bag, 2 muted yellow bags.\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\nbright white bags contain 1 shiny gold bag.\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\nfaded blue bags contain no other bags.\ndotted black bags contain no other bags."
    iex> data |> get_bag_colors_containing_at_least_one("shiny gold")
    4
  """
  def get_bag_colors_containing_at_least_one(bags_rules, bag) do
    bags_rules = parse_bags_rules(bags_rules, &extract_bag_rule/1)

    bags_rules
    |> Map.keys()
    |> Stream.map(&contain_bag?(bag, bags_rules, bags_rules[&1]))
    |> Stream.filter(& &1)
    |> Enum.count()
  end

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day07HandyHaversacks
    iex> data = "shiny gold bags contain 2 dark red bags.\ndark red bags contain 2 dark orange bags.\ndark orange bags contain 2 dark yellow bags.\ndark yellow bags contain 2 dark green bags.\ndark green bags contain 2 dark blue bags.\ndark blue bags contain 2 dark violet bags.\ndark violet bags contain no other bags."
    iex> data |> get_individual_bags_inside_of("shiny gold")
    126
  """

  def get_individual_bags_inside_of(bags_rules, bag) do
    bags_rules = parse_bags_rules(bags_rules, &extract_bag_with_capacity_rule/1)

    bags_rules[bag]
    |> count_bags(bags_rules)
  end

  defp parse_bags_rules(bags_rules, policy) do
    bags_rules
    |> String.split("\n")
    |> Stream.map(policy)
    |> Enum.reduce(%{}, fn {bag, bags}, map -> Map.put(map, bag, bags) end)
  end

  defp extract_bag_rule(bag_rule) do
    [_ | [bag | [bags]]] = @input_regex |> Regex.run(bag_rule)

    bags =
      bags
      |> String.split(", ")
      |> Stream.map(&Regex.run(@bags_regex, &1))
      |> Stream.filter(&(&1 != nil))
      |> Enum.flat_map(fn [_ | match] -> match end)

    {bag, bags}
  end

  defp extract_bag_with_capacity_rule(bag_rule) do
    [_ | [bag | [bags]]] = @input_regex |> Regex.run(bag_rule)

    bags =
      bags
      |> String.split(", ")
      |> Stream.map(&Regex.run(@bags_with_capacity_regex, &1))
      |> Stream.filter(&(&1 != nil))
      |> Enum.map(fn [_ | [number | [name]]] -> {String.to_integer(number), name} end)

    {bag, bags}
  end

  defp contain_bag?(_bag, _bags_rules, []), do: false
  defp contain_bag?(_bag, _bags_rules, nil), do: false

  defp contain_bag?(bag, bags_rules, bags) do
    case bag in bags do
      false ->
        bags
        |> Stream.map(&contain_bag?(bag, bags_rules, bags_rules[&1]))
        |> Enum.reduce(false, &(&1 or &2))

      _ ->
        true
    end
  end

  defp count_bags([], _bags_rules), do: 0

  defp count_bags(bags, bags_rules) do
    bags
    |> Enum.map(fn {quantity, bag} -> quantity + quantity * count_bags(bags_rules[bag], bags_rules) end)
    |> Enum.sum()
  end
end
