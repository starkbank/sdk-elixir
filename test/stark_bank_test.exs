defmodule StarkBankTest do
  use ExUnit.Case
  doctest StarkBank

  test "logs into API" do
    {:ok, _} = StarkBank.login(:sandbox, "username", "usuario@email.com", "password")
  end
end
