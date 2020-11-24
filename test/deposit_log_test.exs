defmodule StarkBankTest.DepositLog do
  use ExUnit.Case

  @tag :deposit_log
  test "query deposit log" do
    StarkBank.Deposit.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :deposit_log
  test "query! deposit log" do
    StarkBank.Deposit.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :deposit_log
  test "query! deposit log with filters" do
    deposit = StarkBank.Deposit.query!(status: "created")
    |> Enum.take(1)
    |> hd()

    StarkBank.Deposit.Log.query!(limit: 1, deposit_ids: [deposit.id], types: "created")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :deposit_log
  test "get deposit log" do
    log = StarkBank.Deposit.Log.query!()
    |> Enum.take(1)
    |> hd()

    {:ok, _log} = StarkBank.Deposit.Log.get(log.id)
  end

  @tag :deposit_log
  test "get! deposit log" do
    log = StarkBank.Deposit.Log.query!()
    |> Enum.take(1)
    |> hd()

    _log = StarkBank.Deposit.Log.get!(log.id)
  end
end
