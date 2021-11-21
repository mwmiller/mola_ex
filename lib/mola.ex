defmodule Mola do
  @moduledoc """
  Compare various poker hand strengths

  No validation is done on the "sanity" of any combination of cards.
  Card rank should be "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"
  Suits should be "c", "d", "h", "s"

  Cards should be provided as a string:
    - "Ac Kc Qc Jc Tc"
    - "AcKcQcJcTc"
    - "🃑🃞🃝🃛🃚"
  or a list of tuples: [{"A", "c"}, {"K", "c"}, {"Q", "c"}, {"J", "c"}, {"T", "c"}]

  Hands which cannot be evaluated are silently stripped from the results

  As long as the cards to hand selection rules are the same, the evaluators should work for
  less popular variants.

  As such, wider boards (with 6 community cards), Pineapple-style (3 personal card
  hold 'em), 8-card stud, and Big-O-ish high (5 personal card Omaha) are all supported.
  Community card (board) games can even vary both.

  Please note that compilation can be very slow while providing very fast hand evaluation.
  """

  @doc """
  Compare 5 card high poker hands
  Selects best 5 cards for each player and then orders players
  Supply:
    - a list of {description, cards} tuples for comparison
    - a list of community cards, if applicable.
    - an options keyword list:
      - hand_selection: (:any, :omaha), defaults to :any
      - deck: (:standard, :short), defaults to :standard

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

      iex> Mola.ranked_high_hands([{"P1", "2c 3c 4c 5c 7s"}, {"P2", "2s 3s 4s 5s 6c"}, {"P3", "Ac As 7h 7c Kc"}])
      [ {"P2", 1608, :six_high_straight}, {"P3", 2534, :aces_and_sevens}, {"P1", 7462, :seven_high} ]

      iex> Mola.ranked_high_hands([{"P1", "2c 3c 4c 5c 7s 5d"}, {"P2", "2s 3s 4s 5s 6c Ks"}, {"P3", "Ac As 7h 7c Kc 7d"}])
      [ {"P3", 251, :sevens_full_over_aces}, {"P2", 1144, :king_high_flush}, {"P1", 5519, :pair_of_fives} ]

      iex> Mola.ranked_high_hands([{"BB", "🃔🃕"}, {"UTG", "AdAh"}, {"CO", "3d 3s"}], "Ac 2c 3h Td 3c")
      [ {"BB", 10, :five_high_straight_flush}, {"CO", 143, :four_treys}, {"UTG", 177, :aces_full_over_treys} ]

      iex> Mola.ranked_high_hands([{"BB", "4c 5d As Tc"}, {"UTG", "Ad Ah Th Ts"}, {"CO", "9c 3s Jc 8d"}], "Ac 2c Td Jd 3c", hand_selection: :omaha)
      [ {"CO", 655, :ace_high_flush}, {"BB", 746, :ace_high_flush}, {"UTG", 1631, :three_aces} ]

      iex> Mola.ranked_high_hands([{"BB", "7c 9c"}, {"UTG", "🃁🂱"}, {"CO", "8d 8s"}], "Ac 6c 8h Td 8c", deck: :short)
      [ {"BB", 6, :nine_high_straight_flush}, {"CO", 55, :four_eights}, {"UTG", 204, :aces_full_over_eights} ]
  """
  def ranked_high_hands(hands, community \\ [], opts \\ [])

  def ranked_high_hands(hands, community, opts) do
    {select, deck, _, _} = parse_opts(opts)

    do_ranking(hands, community, select, deck)
  end

  defp parse_opts(opts) do
    {hs, d, tbd} =
      {Keyword.get(opts, :hand_selection, :any), Keyword.get(opts, :deck, :standard),
       Keyword.get(opts, :deal, community: 0, personal: 0)}

    {c, p} = {Keyword.get(tbd, :community, 0), Keyword.get(tbd, :personal, 0)}

    {hs, d, c, p}
  end

  @doc """
  Enumerates possible wins going word and returns a winner percentage for each supplied hand
  Supply `community` for board games and `seen` for any additional exposed cards

  This does not enforce any rules on board or hand size.

  Options are as per `ranked_high_hands` with an additional keyword list.
  Defaults to:
  - deal: [community: 0, personal: 0]

  Note that dealing additional personal cards is not yet implemented.

  ## Examples

      iex> Mola.equity([{"BB", "Ah Kh"}, {"CO", "Jd Td"}], "Ad Kd Ts", [], deal: [community: 2])
      [{"BB", 51.92}, {"CO", 47.17}, {"BB=CO", 0.91}]

  """

  def equity(hands, community \\ [], seen \\ [], opts \\ [])

  def equity(hands, community, seen, opts) do
    {_, deck, _, tbdp} = parsed = parse_opts(opts)
    nhands = Enum.map(hands, &normalize_hand/1)
    ncomm = normalize_hand(community)
    nseen = normalize_hand(seen)

    remain =
      [ncomm, nseen | nhands]
      |> Enum.reduce(Mola.Poker5High.full_deck(deck), fn {_, c}, d -> d -- c end)

    case tbdp do
      0 -> board_winners(nhands, ncomm, remain, parsed)
      _ -> :unimplemented
    end
  end

  defp board_winners(hands, ncomm, remain, {selection, deck, tbdc, _}) do
    {cd, common} = ncomm

    tbdc
    |> comb(remain)
    |> Flow.from_enumerable()
    |> Flow.map(fn dealt -> hands |> do_ranking({cd, common ++ dealt}, selection, deck) end)
    |> Enum.to_list()
    |> tabulate_results
  end

  defp tabulate_results(winners, acc \\ %{})

  defp tabulate_results([], acc) do
    ways = acc |> Map.values() |> Enum.sum()

    acc
    |> Enum.reduce([], fn {k, v}, a -> [{k, Float.round(100 * v / ways, 2)} | a] end)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
  end

  defp tabulate_results([[] | t], acc), do: tabulate_results(t, acc)

  defp tabulate_results([h | t], acc) do
    {_, top_score, _} = h |> List.first()

    winner_key =
      h
      |> Enum.filter(fn {_, s, _} -> s == top_score end)
      |> Enum.map(fn {d, _, _} -> d end)
      |> Enum.join("=")

    tabulate_results(t, Map.update(acc, winner_key, 1, fn s -> s + 1 end))
  end

  defp do_ranking(hands, [], _, deck) do
    hands
    |> Enum.map(&normalize_hand/1)
    |> Enum.map(fn h -> best5ofpile(h, deck) end)
    |> Enum.reject(fn {_, _, hd} -> hd == :error end)
    |> Enum.sort_by(&elem(&1, 1))
  end

  defp do_ranking(hands, community, :any, deck) do
    {_, common} = normalize_hand(community)

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)
      {desc, cards ++ common}
    end)
    |> do_ranking([], :any, deck)
  end

  defp do_ranking(hands, community, :omaha, deck) do
    {_, common} = normalize_hand(community)
    common_poss = comb(3, common)

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)

      [best | _] =
        common_poss
        |> build_full(comb(2, cards))
        |> Enum.map(fn p -> {desc, p} end)
        |> do_ranking([], :omaha, deck)

      best
    end)
    |> Enum.sort_by(&elem(&1, 1))
  end

  defp best5ofpile({desc, pile}, which) do
    res =
      comb(5, pile)
      |> Enum.map(fn h -> Mola.Poker5High.rank_tuple({desc, h}, which) end)
      |> Enum.reject(fn h -> h == :error end)
      |> Enum.sort_by(&elem(&1, 1))

    case res do
      [best | _] -> best
      [] -> {desc, 1_000_000, :error}
    end
  end

  defp normalize_hand(full) when not is_tuple(full), do: normalize_hand({"placeholder", full})
  defp normalize_hand({_, hand} = full) when is_list(hand), do: full

  defp normalize_hand({desc, hand}) when is_binary(hand) do
    {desc, read_cards(String.graphemes(hand), [])}
  end

  defp read_cards(cards, acc)
  defp read_cards([], acc), do: Enum.reverse(acc)
  defp read_cards([" " | t], acc), do: read_cards(t, acc)

  defp read_cards([c | t], acc) when byte_size(c) > 1,
    do: read_cards(t, [Mola.Unicard.tomola(c) | acc])

  defp read_cards([r | t], acc) do
    [s | rest] = t
    read_cards(rest, [{r, s} | acc])
  end

  defp comb(0, _), do: [[]]
  defp comb(_, []), do: []

  defp comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end

  defp build_full(first, second, acc \\ [])
  defp build_full([], _, acc), do: acc
  defp build_full(_, [], acc), do: acc
  defp build_full([h | t], all, acc), do: build_full(t, all, acc ++ build_item(all, h, []))

  defp build_item([], _, acc), do: acc
  defp build_item(_, [], acc), do: acc
  defp build_item([h | t], i, acc), do: build_item(t, i, acc ++ [h ++ i])
end
