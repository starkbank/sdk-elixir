defmodule StarkBankTest.Balance do
  use ExUnit.Case

  @tag :balance
  test "get! balance" do
    balance = StarkBank.Balance.get!()
    assert !is_nil(balance.amount)
  end

  @tag :balance
  test "get balance" do
    {:ok, balance} = StarkBank.Balance.get()
    assert !is_nil(balance.amount)
  end

  @tag :balance
  test "get balance with user overwrite" do
    project = StarkBank.project(
      environment: :sandbox,
      id: "5637129447145472",
      private_key: "-----BEGIN EC PRIVATE KEY-----
      MHQCAQEEILChZrjrrtFnyCLhcxm/hp+9ljWSmG7Wv9HRugf+FnhkoAcGBSuBBAAK
      oUQDQgAEpIAM/tMqXEfLeR93rRHiFcpDB9I18MrnCJyTVk0MdD1J9wgEbRfvAZEL
      YcEGhTFYp2X3B7K7c4gDDCr0Pu1L3A==
      -----END EC PRIVATE KEY-----"
    )

    {:error, errors} = StarkBank.Balance.get(user: project)
    assert hd(errors).code == "invalidProject"
  end
end
