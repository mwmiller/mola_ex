defmodule Mola do
  @moduledoc """
  Compare various hand strengths

  No validation is done on the "sanity" of any combination of cards.
  Card rank should be "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"
  Suits may be done however you wish, so long as consistent

  Cards should be a string: "Ac Kc Qc Jc Tc"
      or a list of tuples: [{"A", "c"}, {"K", "c"}, {"Q", "c"}, {"J", "c"}, {"T", "c"}]

  Hands which cannot be evaluated are silently stripped from the results
  """

  @doc """
  Compare 5 card high poker hands from all personal cards
  Selects best 5 cards for each player and then orders players
  Supply a list of {description, cards} tuples for comparison 

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

  iex> Mola.best_five_card_high([{"P1", "2c 3c 4c 5c 7s"}, {"P2", "2s 3s 4s 5s 6c"}, {"P3", "Ac As 7h 7c Kc"}])
  [
    {"P2", 1608, :six_high_straight},
    {"P3", 2534, :aces_and_sevens},
    {"P1", 7462, :seven_high}
  ]
  iex> Mola.best_five_card_high([{"P1", "2c 3c 4c 5c 7s 5d"}, {"P2", "2s 3s 4s 5s 6c Ks"}, {"P3", "Ac As 7h 7c Kc 7d"}])
  [
    {"P3", 251, :sevens_full_over_aces},
    {"P2", 1144, :king_high_flush},
    {"P1", 5519, :pair_of_fives}
  ]
  """
  def best_five_card_high(hands) do
    hands
    |> Enum.map(&normalize_hand/1)
    |> Enum.map(&best5ofpile/1)
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

  @doc """
  Compare hold 'em hands built from community and personal cards
  Selects best 5 cards for each player and then orders players
  Supply a community cards and list of {description, cards} tuples for comparison 

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

  iex> Mola.best_holdem_high("Ac 2c 3h Td 3c", [{"BB", "4c 5c"}, {"UTG", "Ad Ah"}, {"CO", "3d 3s"}])
  [
    {"BB", 10, :five_high_straight_flush},
    {"CO", 143, :four_treys},
    {"UTG", 177, :aces_full_over_treys}
  ]
  """
  def best_holdem_high(community, hands) do
    {_, common} = normalize_hand({"community", community})

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)
      {desc, cards ++ common}
    end)
    |> best_five_card_high
  end

  @doc """
  Compare Omaha high hands built from community and personal cards
  Selects best 5 cards for each player and then orders players
  Supply a community cards and list of {description, cards} tuples for comparison 

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

  iex> Mola.best_omaha_high("Ac 2c Td Jd 3c", [{"BB", "4c 5d As Tc"}, {"UTG", "Ad Ah Th Ts"}, {"CO", "9c 3s Jc 8d"}])
  [
    {"CO", 655, :ace_high_flush},
    {"BB", 746, :ace_high_flush},
    {"UTG", 1631, :three_aces}
  ]
  """
  def best_omaha_high(community, hands) do
    {_, common} = normalize_hand({"community", community})
    common_poss = comb(3, common)

    hands
    |> Enum.map(fn h ->
      {desc, cards} = normalize_hand(h)

      [best | _] =
        common_poss
        |> build_full(comb(2, cards))
        |> Enum.map(fn p -> {desc, p} end)
        |> best_five_card_high

      best
    end)
    |> Enum.reject(fn h -> h == :error end)
    |> Enum.sort_by(&elem(&1, 1))
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
