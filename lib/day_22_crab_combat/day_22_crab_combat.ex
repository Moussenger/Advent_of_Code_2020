defmodule AdventOfCode.Day22CrabCombat do

  # import AdventOfCode.Day22CrabCombat
  # file = "lib/day_22_crab_combat/input.txt" |> File.read!()
  def get_winner_score(data) do
    data
    |> String.split("\n\n")
    |> Enum.map(&(String.split(&1, "\n")))
    |> Enum.map(&(List.delete_at(&1, 0)))
    |> Enum.map(&(Enum.map(&1, fn card -> String.to_integer(card) end)))
    |> List.to_tuple()
    |> play()
    |> Enum.reverse()
    |> score(1, 0)
  end


  defp play({[], player2}), do: player2
  defp play({player1, []}), do: player1
  defp play({[card1 | cards1], [card2 | cards2]}) when card1 > card2, do: {cards1 ++ [card1, card2], cards2} |> play()
  defp play({[card1 | cards1], [card2 | cards2]}) when card2 > card1, do: {cards1, cards2 ++ [card2, card1]} |> play()

  defp score([], _position, scoring), do: scoring
  defp score([card | cards], position, scoring) do
    score(cards, position + 1, scoring + card * position)
  end
end
