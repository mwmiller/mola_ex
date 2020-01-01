defmodule MolaPoker5HighTest do
  use ExUnit.Case
  doctest Mola.Poker5High
  alias Mola.Poker5High, as: P

  test "deck sizes" do
    assert P.full_deck(:standard) |> Enum.count() == 52
    assert P.full_deck(:short) |> Enum.count() == 36
  end

  test "proper rank standard" do
    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"A", "c"}], :standard) ==
             {1609, :five_high_straight}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"A", "s"}], :standard) ==
             {10, :five_high_straight_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "s"}], :standard) ==
             {9, :six_high_straight_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"}], :standard) ==
             {1608, :six_high_straight}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"7", "d"}], :standard) ==
             {7462, :seven_high}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"7", "s"}], :standard) ==
             {1599, :seven_high_flush}

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"6", "s"}, {"7", "s"}], :standard) ==
             {1598, :seven_high_flush}

    assert P.rank([{"2", "♠️"}, {"3", "♠️"}, {"4", "♠️"}, {"6", "♠️"}, {"7", "♠️"}], :standard) ==
             {1598, :seven_high_flush}
  end

  test "proper rank short" do
    assert P.rank([{"6", "s"}, {"7", "s"}, {"8", "s"}, {"9", "s"}, {"A", "s"}], :short) ==
             {6, :nine_high_straight_flush}

    assert P.rank([{"6", "s"}, {"7", "c"}, {"8", "s"}, {"9", "s"}, {"A", "s"}], :short) ==
             {276, :nine_high_straight}

    assert P.rank([{"6", "s"}, {"7", "s"}, {"8", "s"}, {"9", "s"}, {"J", "c"}], :short) ==
             {1404, :jack_high}

    assert P.rank([{"6", "s"}, {"7", "s"}, {"8", "s"}, {"9", "s"}, {"Q", "s"}], :short) ==
             {194, :queen_high_flush}

    assert P.rank([{"6", "s"}, {"7", "s"}, {"8", "s"}, {"Q", "s"}, {"T", "s"}], :short) ==
             {193, :queen_high_flush}

    assert P.rank([{"6", "s"}, {"6", "c"}, {"6", "d"}, {"7", "s"}, {"7", "d"}], :short) ==
             {270, :sixes_full_over_sevens}
  end

  test "improper rank" do
    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}], :standard) == :error

    assert P.rank([{"7", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"}], :standard) ==
             :error

    assert P.rank([{"2", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"A", "c"}], :short) ==
             :error

    assert P.rank([{"6", "s"}, {"7", "s"}, {"8", "s"}, {"Q", "s"}], :short) == :error

    assert P.rank([{"7", "s"}, {"8", "s"}, {"6", "s"}, {"T", "s"}, {"Q", "d"}], :short) ==
             :error

    assert_raise(UndefinedFunctionError, fn ->
      P.rank({"7", "s"}, {"3", "s"}, {"4", "s"}, {"5", "s"}, {"6", "d"}, :standard)
    end)
  end
end
