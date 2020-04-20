defmodule StarkBankTest.Balance do
  use ExUnit.Case

  @tag :balance
  test "get balance" do
    balance = StarkBank.Balance.get!()
    assert !is_nil(balance.amount)
  end
end
