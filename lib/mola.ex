defmodule Mola do
  @moduledoc """
  Compare various hand strengths

  No validation is done on the "sanity" of any combination of cards.
  Card rank should be "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"
  Suits may be done however you wish, so long as consistent

  Cards should be a string: "Ac Kc Qc Jc Tc"
      or a list of tuples: [{"A", "c"}, {"K", "c"}, {"Q", "c"}, {"J", "c"}, {"T", "c"}]

  Hands which cannot be evaluated are silently stripped from the results

  As long as the cards to hand selection rules are the same, the evaluators should work for
  less popular variants.

  - Omit community cards for games with only personal cards.
  - :holdem for games with selection among all community and personal cards
  - :omaha for games with 3 board and 2 personal cards

  As such, wider boards (with 6 community cards), Pineapple-style (3 personal card
  hold 'em), 8-card stud, and Big-O-ish high (5 personal card Omaha) are all supported.
  Community card (board) games can even vary both.
  """

  @doc """
  Compare 5 card high poker hands from all personal cards
  Selects best 5 cards for each player and then orders players
  Supply:
    - a list of {description, cards} tuples for comparison
    - a list of community cards, if applicable.
    - a selection strategy atom (:holdem or :omaha)

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

  # Defaults to all personal cards
  iex> Mola.ranked_high_hands([{"P1", "2c 3c 4c 5c 7s"}, {"P2", "2s 3s 4s 5s 6c"}, {"P3", "Ac As 7h 7c Kc"}])
  [
    {"P2", 1608, :six_high_straight},
    {"P3", 2534, :aces_and_sevens},
    {"P1", 7462, :seven_high}
  ]
  iex> Mola.ranked_high_hands([{"P1", "2c 3c 4c 5c 7s 5d"}, {"P2", "2s 3s 4s 5s 6c Ks"}, {"P3", "Ac As 7h 7c Kc 7d"}])
  [
    {"P3", 251, :sevens_full_over_aces},
    {"P2", 1144, :king_high_flush},
    {"P1", 5519, :pair_of_fives}
  ]
  # Defaults to :holdem
  iex> Mola.ranked_high_hands([{"BB", "4c 5c"}, {"UTG", "Ad Ah"}, {"CO", "3d 3s"}], "Ac 2c 3h Td 3c")
  [
    {"BB", 10, :five_high_straight_flush},
    {"CO", 143, :four_treys},
    {"UTG", 177, :aces_full_over_treys}
  ]
  iex> Mola.ranked_high_hands([{"BB", "4c 5d As Tc"}, {"UTG", "Ad Ah Th Ts"}, {"CO", "9c 3s Jc 8d"}], "Ac 2c Td Jd 3c", :omaha)
  [
    {"CO", 655, :ace_high_flush},
    {"BB", 746, :ace_high_flush},
    {"UTG", 1631, :three_aces}
  ]
  """
  def ranked_high_hands(hands, community \\ [], selection \\ :holdem)

  def ranked_high_hands(hands, [], _) do
    hands
    |> Enum.map(&normalize_hand/1)
    |> Enum.map(&best5ofpile/1)
    |> Enum.sort_by(&elem(&1, 1))
  end

  def ranked_high_hands(hands, community, :holdem) do
    {_, common} = normalize_hand({"community", community})

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)
      {desc, cards ++ common}
    end)
    |> ranked_high_hands
  end

  def ranked_high_hands(hands, community, :omaha) do
    {_, common} = normalize_hand({"community", community})
    common_poss = comb(3, common)

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)

      [best | _] =
        common_poss
        |> build_full(comb(2, cards))
        |> Enum.map(fn p -> {desc, p} end)
        |> ranked_high_hands

      best
    end)
    |> Enum.sort_by(&elem(&1, 1))
  end

  defp best5ofpile({desc, pile}) do
    [best | _] =
      comb(5, pile)
      |> Enum.map(fn h -> Mola.PokerHigh525.rank_tuple({desc, h}) end)
      |> Enum.reject(fn h -> h == :error end)
      |> Enum.sort_by(&elem(&1, 1))

    best
  end

  defp normalize_hand({_, hand} = full) when is_list(hand), do: full

  defp normalize_hand({desc, hand}) when is_binary(hand) do
    cards =
      hand
      |> String.split(" ", trim: true)
      |> Enum.map(fn s -> s |> String.split("", trim: true) |> List.to_tuple() end)

    {desc, cards}
  end

  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end

  def build_full(first, second, acc \\ [])
  def build_full([], _, acc), do: acc
  def build_full(_, [], acc), do: acc
  def build_full([h | t], all, acc), do: build_full(t, all, acc ++ build_item(all, h, []))

  def build_item([], _, acc), do: acc
  def build_item(_, [], acc), do: acc
  def build_item([h | t], i, acc), do: build_item(t, i, acc ++ [h ++ i])
end
