defmodule MolaTest do
  use ExUnit.Case
  doctest Mola

  test "five card high" do
    assert Mola.ranked_high_hands([{"mwm", "Ac As 5d 3c Kh"}, {"icydee", "Ah Ad Kc 4d 3d"}]) ==
             [
               {"mwm", 3376, :pair_of_aces},
               {"icydee", 3378, :pair_of_aces}
             ]

    assert Mola.ranked_high_hands([
             {"mwm", "Ac As 5d 3c Kh 7c"},
             {"icydee", "Ah Ad Kc 4d 3d Kd"}
           ]) == [
             {"icydee", 2476, :aces_and_kings},
             {"mwm", 3367, :pair_of_aces}
           ]

    assert Mola.ranked_high_hands([
             {"mwm", "Ac As 5c 3c Kh 7c 2c"},
             {"icydee", "Ah Ad Kc 4d 3d Kd 4c"}
           ]) == [
             {"mwm", 810, :ace_high_flush},
             {"icydee", 2476, :aces_and_kings}
           ]
  end

  test "holdem" do
    assert Mola.ranked_high_hands([{"hero", "9c 8c"}, {"villian", "Ad Ah"}], "Ac Kc Qc Jc Tc") ==
             [
               {"hero", 1, :royal_flush},
               {"villian", 1, :royal_flush}
             ]

    assert Mola.ranked_high_hands([{"hero", "Jd Js"}, {"villian", "Ad Ah"}], "Ac Kc Qc Jc Jh") ==
             [
               {"hero", 47, :four_jacks},
               {"villian", 169, :aces_full_over_jacks}
             ]

    assert Mola.ranked_high_hands([{"hero", "As Js"}, {"villian", "Ad Kh"}], "Ac 9d 6s 5h 2s") ==
             [{"villian", 3355, :pair_of_aces}, {"hero", 3436, :pair_of_aces}]
  end

  test "omaha" do
    assert Mola.ranked_high_hands(
             [{"hero", "9c 8c As Jh"}, {"villian", "Ad Ah Kd Kh"}],
             "Ac Kc Qc Jc Tc",
             :omaha
           ) ==
             [{"hero", 3, :queen_high_straight_flush}, {"villian", 1600, :ace_high_straight}]

    assert Mola.ranked_high_hands(
             [
               {"hero", "Jd Js Qs Qd"},
               {"villian", "Ad Ah Tc 9c"}
             ],
             "Ac Kc Qc Jc Jh",
             :omaha
           ) ==
             [{"villian", 2, :king_high_straight_flush}, {"hero", 47, :four_jacks}]

    assert Mola.ranked_high_hands(
             [
               {"hero", "As Js 8c 7d"},
               {"villian", "Ad Kh 3c 4h"}
             ],
             "Ac 9d 6s 5h 2s",
             :omaha
           ) ==
             [{"hero", 1605, :nine_high_straight}, {"villian", 1608, :six_high_straight}]
  end
end
