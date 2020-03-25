defmodule StarkbankTest.Balance do
  use ExUnit.Case

  test "get balance" do
    user = StarkbankTest.Credentials.project()
    balance = StarkBank.Balance.get!(user)
    assert !is_nil(balance.amount)
  end
end
