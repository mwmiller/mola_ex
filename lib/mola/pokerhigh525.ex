defmodule Mola.PokerHigh525 do
  for vals <-
        File.read!(Application.app_dir(:mola, "priv/poker_high_52_5.tsv"))
        |> String.split("\n", trim: true) do
    [rstr, cards, type, desc] = vals |> String.split("\t", trim: true)
    {rank, ""} = Integer.parse(rstr)
    [a, b, c, d, e] = cards |> String.split() |> Enum.sort()
    id = desc |> String.downcase() |> String.replace([" ", "-"], "_") |> String.to_atom()

    case type in ["SF", "F"] do
      # Suitedness matters
      true ->
        def rank([
              {unquote(a), s},
              {unquote(b), s},
              {unquote(c), s},
              {unquote(d), s},
              {unquote(e), s}
            ]),
            do: {unquote(rank), unquote(id)}

      false ->
        def rank([
              {unquote(a), _},
              {unquote(b), _},
              {unquote(c), _},
              {unquote(d), _},
              {unquote(e), _}
            ]),
            do: {unquote(rank), unquote(id)}
    end
  end

  def rank(_), do: :error

  def rank_tuple({desc, cards}) when is_binary(cards) do
    hand =
      cards
      |> String.split(" ", trim: true)
      |> Enum.map(fn s -> s |> String.split("", trim: true) |> List.to_tuple() end)

    rank_tuple({desc, hand})
  end

  def rank_tuple({desc, cards}) when is_list(cards) do
    {rank, hand} = cards |> Enum.sort_by(&elem(&1, 0)) |> rank()
    {desc, rank, hand}
  end
end
