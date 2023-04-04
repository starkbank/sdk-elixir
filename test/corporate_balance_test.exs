defmodule StarkBankTest.CorporateBalance do
  use ExUnit.Case

  @tag :corporate_balance
  test "get corporate balance test" do
    {:ok, corporate_balance} = StarkBank.CorporateBalance.get()

    assert !is_nil(corporate_balance.id)
  end

  @tag :corporate_balance
  test "get! corporate balance test" do
    corporate_balance = StarkBank.CorporateBalance.get!()

    assert !is_nil(corporate_balance.id)
  end
end
