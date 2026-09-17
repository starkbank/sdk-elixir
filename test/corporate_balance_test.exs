defmodule StarkBankTest.CorporateBalance do
  use ExUnit.Case

  @tag :corporate_balance
  test "get! corporate_balance" do
    balance = StarkBank.CorporateBalance.get!()
    assert !is_nil(balance.amount)
  end

  @tag :corporate_balance
  test "get corporate_balance" do
    {:ok, balance} = StarkBank.CorporateBalance.get()
    assert !is_nil(balance.amount)
  end
end
