defmodule AdventOfCode.Day07HandyHaversacks do
  @input_regex ~r/^(\w+ \w+) bags contain (.*).$/
  @bags_regex ~r/,?\s?\d (\w+ \w+) bag[s]?/

  @doc ~S"""
  ## Examples
    iex> import AdventOfCode.Day07HandyHaversacks
    iex> data = "light red bags contain 1 bright white bag, 2 muted yellow bags.\ndark orange bags contain 3 bright white bags, 4 muted yellow bags.\nbright white bags contain 1 shiny gold bag.\nmuted yellow bags contain 2 shiny gold bags, 9 faded blue bags.\nshiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.\ndark olive bags contain 3 faded blue bags, 4 dotted black bags.\nvibrant plum bags contain 5 faded blue bags, 6 dotted black bags.\nfaded blue bags contain no other bags.\ndotted black bags contain no other bags."
    iex> data |> get_bag_colors_containing_at_least_one("shiny gold")
    4
  """
  def get_bag_colors_containing_at_least_one(bags_rules, bag) do
    bags_rules = parse_bags_rules(bags_rules)

    bags_rules
    |> Map.keys()
    |> Stream.map(&contain_bag?(bag, bags_rules, bags_rules[&1]))
    |> Stream.filter(& &1)
    |> Enum.count()
  end

  defp parse_bags_rules(bags_rules) do
    bags_rules
    |> String.split("\n")
    |> Stream.map(&extract_bag_rule/1)
    |> Enum.reduce(%{}, fn {bag, bags}, map -> Map.put(map, bag, bags) end)
  end

  def extract_bag_rule(bag_rule) do
    [_ | [bag | [bags]]] = @input_regex |> Regex.run(bag_rule)

    bags =
      bags
      |> String.split(", ")
      |> Stream.map(&Regex.run(@bags_regex, &1))
      |> Stream.filter(&(&1 != nil))
      |> Enum.flat_map(fn [_ | match] -> match end)

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
end
