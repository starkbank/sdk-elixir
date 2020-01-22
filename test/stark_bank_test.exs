defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  test "greets the world" do
    assert StarkBank.hello() == :world
  end
end
