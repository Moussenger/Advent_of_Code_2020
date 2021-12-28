defmodule AdventOfCode.Day22CrabCombat do

  # import AdventOfCode.Day22CrabCombat
  # file = "lib/day_22_crab_combat/input.txt" |> File.read!()
  def get_winner_score(data) do
    data
    |> parse_decks()
    |> play()
    |> Enum.reverse()
    |> score(1, 0)
  end

  def get_recursive_winner_score(data) do
    data
    |> parse_decks()
    |> recursive_play(MapSet.new)
    |> (fn {_, score} -> Enum.reverse(score) end).()
    |> score(1, 0)
  end

  defp recursive_play({[], player2}, _past), do: {:player2, player2}
  defp recursive_play({player1, []}, _past), do: {:player1, player1}
  defp recursive_play({player1, player2}, past) do
    hash = deck_hash(player1, player2)

    case MapSet.member?(past, hash) do
      true -> {:player1, player1}
      false -> play_recursive_round(player1, player2, MapSet.put(past, hash))
    end
  end

  defp play_recursive_round([card1 | cards1], [card2 | cards2], past) when card1 <= length(cards1) and card2 <= length(cards2) do
    case recursive_play({Enum.slice(cards1, 0, card1), Enum.slice(cards2, 0, card2)}, MapSet.new) do
      {:player1, _} -> {cards1 ++ [card1, card2], cards2} |> recursive_play(past)
      {:player2, _} -> {cards1, cards2 ++ [card2, card1]} |> recursive_play(past)
    end
  end
  defp play_recursive_round([card1 | cards1], [card2 | cards2], past) when card1 > card2, do: {cards1 ++ [card1, card2], cards2} |> recursive_play(past)
  defp play_recursive_round([card1 | cards1], [card2 | cards2], past) when card2 > card1, do: {cards1, cards2 ++ [card2, card1]} |> recursive_play(past)

  defp deck_hash(player1, player2) do
    [Enum.join(player1, ","), Enum.join(player2, ",")] |> Enum.join("--")
  end

  defp play({[], player2}), do: player2
  defp play({player1, []}), do: player1
  defp play({[card1 | cards1], [card2 | cards2]}) when card1 > card2, do: {cards1 ++ [card1, card2], cards2} |> play()
  defp play({[card1 | cards1], [card2 | cards2]}) when card2 > card1, do: {cards1, cards2 ++ [card2, card1]} |> play()

  defp score([], _position, scoring), do: scoring
  defp score([card | cards], position, scoring) do
    score(cards, position + 1, scoring + card * position)
  end

  defp parse_decks(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&(String.split(&1, "\n")))
    |> Enum.map(&(List.delete_at(&1, 0)))
    |> Enum.map(&(Enum.map(&1, fn card -> String.to_integer(card) end)))
    |> List.to_tuple()
  end
end
