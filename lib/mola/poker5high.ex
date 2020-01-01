defmodule Mola.Poker5High do
  for {which, file, ranks} <- [
        {:standard, "poker_high_52_5.tsv",
         ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]},
        {:short, "poker_high_36_5.tsv", ["6", "7", "8", "9", "T", "J", "Q", "K", "A"]}
      ] do
    for vals <-
          File.read!(Application.app_dir(:mola, "priv/" <> file))
          |> String.split("\n", trim: true) do
      [rstr, cards, type, desc] = vals |> String.split("\t", trim: true)
      {rank, ""} = Integer.parse(rstr)
      [a, b, c, d, e] = cards |> String.split() |> Enum.sort()
      id = desc |> String.downcase() |> String.replace([" ", "-"], "_") |> String.to_atom()

      case type in ["SF", "F"] do
        # Suitedness matters
        true ->
          def rank(
                [
                  {unquote(a), s},
                  {unquote(b), s},
                  {unquote(c), s},
                  {unquote(d), s},
                  {unquote(e), s}
                ],
                unquote(which)
              ),
              do: {unquote(rank), unquote(id)}

        false ->
          def rank(
                [
                  {unquote(a), _},
                  {unquote(b), _},
                  {unquote(c), _},
                  {unquote(d), _},
                  {unquote(e), _}
                ],
                unquote(which)
              ),
              do: {unquote(rank), unquote(id)}
      end
    end

    def rank(_, unquote(which)), do: :error

    def rank_tuple({desc, cards}, unquote(which)) do
      case cards |> Enum.sort_by(&elem(&1, 0)) |> rank(unquote(which)) do
        {rank, hand} -> {desc, rank, hand}
        :error -> :error
      end
    end

    # This works up until the point where decks add or remove suits
    deck = ranks |> Enum.reduce([], fn r, a -> [{r, "c"}, {r, "d"}, {r, "h"}, {r, "s"} | a] end)
    def full_deck(unquote(which)), do: unquote(deck)
  end
end
