defmodule StarkbankTest.Balance do
  use ExUnit.Case

  @tag :skip
  test "get balance" do
    user = StarkbankTest.Credentials.project()
    balance = StarkBank.Balance.get!(user)
    assert !is_nil(balance.amount)
  end
end
