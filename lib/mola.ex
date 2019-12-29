defmodule Mola do
  @moduledoc """
  Compare various hand strengths

  No validation is done on the "sanity" of any combination of cards.
  Card rank should be "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"
  Suits may be done however you wish, so long as consistent

  Hand should be a string: "Ac Kc Qc Jc Tc"
      or a list of tuples: [{"A", "c"}, {"K", "c"}, {"Q", "c"}, {"J", "c"}, {"T", "c"}]
  """

  @doc """
  Compare 5 card high poker hands
  Supply a list of {description, hand} tuples for comparison

  Returns a sorted list of tuples: [{description, rank, :hand_descriptor}]

  ## Examples

  iex> Mola.five_card_high([{"P1", "2c 3c 4c 5c 7s"}, {"P2", "2s 3s 4s 5s 6c"}, {"P3", "Ac As 7h 7c Kc"}])
  [
    {"P2", 1608, :six_high_straight},
    {"P3", 2534, :aces_and_sevens},
    {"P1", 7462, :seven_high}
  ]
  """
  def five_card_high(hands) do
    hands
    |> Enum.map(&Mola.PokerHigh525.rank_tuple/1)
    |> Enum.sort_by(&elem(&1, 1))
  end
end
