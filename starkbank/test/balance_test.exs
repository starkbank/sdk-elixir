defmodule StarkBankTest.Balance do
  use ExUnit.Case

  @tag :exclude
  test "get balance" do
    user = StarkBankTest.Credentials.project()
    balance = StarkBank.Balance.get!(user)
    assert !is_nil(balance.amount)
  end
end
