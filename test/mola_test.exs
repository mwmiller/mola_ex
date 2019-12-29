defmodule MolaTest do
  use ExUnit.Case
  doctest Mola

  test "greets the world" do
    assert Mola.hello() == :world
  end
end
