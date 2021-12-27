defmodule AdventOfCode.Day21AllergementAssessment do

  # import AdventOfCode.Day21AllergementAssessment
  # file = "lib/day_21_allergement_assessment/input.txt" |> File.read!()
  def count_non_allergens(data) do
    input = parse_input(data)

    input
    |> count_ingredients()
    |> Map.drop(get_ingredients_with_allergens(input))
    |> Map.values()
    |> Enum.sum()
  end

  def get_ingredients_sorted_by_allergen(data) do
    input = parse_input(data)

    get_ingredients_associated_with_allergens(input)
    |> Map.to_list()
    |> Enum.map( fn {allergen, ingredients} -> {allergen, MapSet.to_list(ingredients)} end)
    |> pair_ingredients_with_allergens([])
    |> Enum.sort_by(fn {allergen, _ingredient} -> allergen end)
    |> Enum.map(fn {_, ingredient} -> ingredient end)
    |> Enum.join(",")
  end

  defp pair_ingredients_with_allergens([], paired), do: paired
  defp pair_ingredients_with_allergens(allergens, paired) do
    case Enum.find(allergens, fn {_allegen, ingredients} -> length(ingredients) == 1 end) do
      nil -> raise 'Allergens can not be paired'
      allergen -> pair_ingredients_with_allergen(allergen, allergens, paired)
    end
  end

  defp pair_ingredients_with_allergen({allergen, [ingredient|_]} = pair, allergens, paired) do
    allergens = allergens
    |> List.delete(pair)
    |> Enum.map(fn {allergen, ingredients} ->{allergen,  List.delete(ingredients, ingredient)} end)

    pair_ingredients_with_allergens(allergens, [{allergen, ingredient} | paired])
  end

  defp get_ingredients_with_allergens(input) do
    input
    |> get_ingredients_associated_with_allergens()
    |> Map.values()
    |> Enum.map(&MapSet.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp get_ingredients_associated_with_allergens(input) do
    input
    |> associate_input_allergens([])
    |> List.flatten()
    |> associate_allergens(%{})
  end

  defp associate_allergens([], association), do: association
  defp associate_allergens([{allergen, ingredients} | allergens], association) do
      association = Map.update(association, allergen, MapSet.new(ingredients), &(MapSet.intersection(&1, MapSet.new(ingredients))))
      associate_allergens(allergens, association)
  end

  defp associate_input_allergens([], associated), do: associated
  defp associate_input_allergens([input | input_allergens], associated) do
    associate_input_allergens(input_allergens, [associate_input_ingredientes_with_allergens(input) | associated])
  end

  defp associate_input_ingredientes_with_allergens([allergens | [ingredients | []]]) do
    associate_input_ingredientes_with_allergen(allergens, ingredients, [])
  end

  defp associate_input_ingredientes_with_allergen([], _ingredients, associated), do: associated
  defp associate_input_ingredientes_with_allergen([allergen | allergens], ingredients, associated) do
      associate_input_ingredientes_with_allergen(allergens, ingredients, [{allergen, ingredients} | associated])
  end

  defp count_ingredients(input) do
    input
    |> Enum.map(&(Enum.at(&1, 1)))
    |> List.flatten()
    |> Enum.reduce(%{}, &(Map.update(&2, &1, 1, (fn value -> value+1 end))))
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Stream.map(&(String.replace(&1, "(", " ")))
    |> Stream.map(&(String.replace(&1, ")", "")))
    |> Stream.map(&(String.split(&1, "contains")))
    |> Stream.map(&(Enum.map(&1, fn line -> String.trim(line) end)))
    |> Stream.map(&(Enum.reverse(&1)))
    |> Stream.map(&(Enum.map(&1, fn line -> String.replace(line, ",", "") end)))
    |> Enum.map(&(Enum.map(&1, fn line -> String.split(line, " ") end)))
  end
end
