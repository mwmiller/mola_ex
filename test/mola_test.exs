defmodule MolaTest do
  use ExUnit.Case
  doctest Mola

  test "five card high" do
    assert Mola.best_five_card_high([{"mwm", "Ac As 5d 3c Kh"}, {"icydee", "Ah Ad Kc 4d 3d"}]) ==
             [
               {"mwm", 3376, :pair_of_aces},
               {"icydee", 3378, :pair_of_aces}
             ]

    assert Mola.best_five_card_high([
             {"mwm", "Ac As 5d 3c Kh 7c"},
             {"icydee", "Ah Ad Kc 4d 3d Kd"}
           ]) == [
             {"icydee", 2476, :aces_and_kings},
             {"mwm", 3367, :pair_of_aces}
           ]

    assert Mola.best_five_card_high([
             {"mwm", "Ac As 5c 3c Kh 7c 2c"},
             {"icydee", "Ah Ad Kc 4d 3d Kd 4c"}
           ]) == [
             {"mwm", 810, :ace_high_flush},
             {"icydee", 2476, :aces_and_kings}
           ]
  end

  test "hold 'em high" do
    assert Mola.best_holdem_high("Ac Kc Qc Jc Tc", [{"hero", "9c 8c"}, {"villian", "Ad Ah"}]) == [
             {"hero", 1, :royal_flush},
             {"villian", 1, :royal_flush}
           ]

    assert Mola.best_holdem_high("Ac Kc Qc Jc Jh", [{"hero", "Jd Js"}, {"villian", "Ad Ah"}]) == [
             {"hero", 47, :four_jacks},
             {"villian", 169, :aces_full_over_jacks}
           ]

    assert Mola.best_holdem_high("Ac 9d 6s 5h 2s", [{"hero", "As Js"}, {"villian", "Ad Kh"}]) ==
             [{"villian", 3355, :pair_of_aces}, {"hero", 3436, :pair_of_aces}]
  end

  test "omaha high" do
    assert Mola.best_omaha_high("Ac Kc Qc Jc Tc", [
             {"hero", "9c 8c As Jh"},
             {"villian", "Ad Ah Kd Kh"}
           ]) ==
             [{"hero", 3, :queen_high_straight_flush}, {"villian", 1600, :ace_high_straight}]

    assert Mola.best_omaha_high("Ac Kc Qc Jc Jh", [
             {"hero", "Jd Js Qs Qd"},
             {"villian", "Ad Ah Tc 9c"}
           ]) ==
             [{"villian", 2, :king_high_straight_flush}, {"hero", 47, :four_jacks}]

    assert Mola.best_omaha_high("Ac 9d 6s 5h 2s", [
             {"hero", "As Js 8c 7d"},
             {"villian", "Ad Kh 3c 4h"}
           ]) ==
             [{"hero", 1605, :nine_high_straight}, {"villian", 1608, :six_high_straight}]
  end
end
