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
      id: "9999999999999999",
      private_key: "-----BEGIN EC PRIVATE KEY-----
      MHQCAQEEIBEcEJZLk/DyuXVsEjz0w4vrE7plPXhQxODvcG1Jc0WToAcGBSuBBAAK
      oUQDQgAE6t4OGx1XYktOzH/7HV6FBukxq0Xs2As6oeN6re1Ttso2fwrh5BJXDq75
      mSYHeclthCRgU8zl6H1lFQ4BKZ5RCQ==
      -----END EC PRIVATE KEY-----"
    )

    {:error, errors} = StarkBank.Balance.get(user: project)
    assert hd(errors).code == "invalidCredentials"
  end
end
