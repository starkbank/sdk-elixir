defmodule StarkbankTest do
  use ExUnit.Case
  doctest Starkbank

  test "greets the world" do
    assert Starkbank.hello() == :world
  end
end
