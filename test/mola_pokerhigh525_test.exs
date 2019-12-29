defmodule MolaPokerHigh525Test do
  use ExUnit.Case
  doctest Mola.PokerHigh525
  alias Mola.PokerHigh525, as: P

  test "proper rank" do
    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"A", "c"}]) ==
             {1609, :five_high_straight}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"A", "s"}]) ==
             {10, :five_high_straight_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "s"}]) ==
             {9, :six_high_straight_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"}]) ==
             {1608, :six_high_straight}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"7", "d"}]) ==
             {7462, :seven_high}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"7", "s"}]) ==
             {1599, :seven_high_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"6", "s"}, {"7", "s"}]) ==
             {1598, :seven_high_flush}

    assert P.rank([{"2", "♠️"}, {"3", "♠️"}, {"4", "♠️"}, {"6", "♠️"}, {"7", "♠️"}]) ==
             {1598, :seven_high_flush}
  end

  test "improper rank" do
    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}]) == :error
    assert P.rank([{"7", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"}]) == :error

    assert_raise(UndefinedFunctionError, fn ->
      P.rank({"7", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"})
    end)
  end
end
