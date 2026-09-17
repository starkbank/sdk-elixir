defmodule StarkBankTest.VerifiedTransfer do
  use ExUnit.Case

  @tag :verified_transfer
  test "create verified_transfer" do
    {:ok, [account]} =
      StarkBank.VerifiedAccount.create([StarkBankTest.VerifiedAccount.example_verified_account()])

    {:ok, transfers} =
      StarkBank.VerifiedTransfer.create([example_verified_transfer(account.id)])

    transfer = transfers |> hd
    assert !is_nil(transfer)
    assert transfer.rules == [%StarkBank.Transfer.Rule{key: "resendingLimit", value: 5}]
  end

  @tag :verified_transfer
  test "create! verified_transfer" do
    account =
      StarkBank.VerifiedAccount.create!([StarkBankTest.VerifiedAccount.example_verified_account()])
      |> hd

    transfer =
      StarkBank.VerifiedTransfer.create!([example_verified_transfer(account.id)]) |> hd

    assert !is_nil(transfer)
  end

  @tag :verified_transfer
  test "create verified_transfer with rules as Transfer.Rule structs" do
    account =
      StarkBank.VerifiedAccount.create!([StarkBankTest.VerifiedAccount.example_verified_account()])
      |> hd

    transfer_with_struct_rules = %{
      example_verified_transfer(account.id)
      | rules: [%StarkBank.Transfer.Rule{key: "resendingLimit", value: 5}]
    }

    {:ok, transfers} = StarkBank.VerifiedTransfer.create([transfer_with_struct_rules])
    transfer = transfers |> hd
    assert !is_nil(transfer)
    assert transfer.rules == [%StarkBank.Transfer.Rule{key: "resendingLimit", value: 5}]
  end

  def example_verified_transfer(account_id) do
    %StarkBank.VerifiedTransfer{
      amount: 10,
      account_id: account_id,
      external_id: "elixir-#{:rand.uniform(9999999999)}",
      rules: [%{"key" => "resendingLimit", "value" => 5}]
    }
  end
end
