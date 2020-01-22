defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  test "logs into API" do
    assert StarkBank.login()
  end
end
