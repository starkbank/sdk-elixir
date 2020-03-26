defmodule StarkBankTest.TransferLog do
  use ExUnit.Case

  @tag :transfer_log
  test "query transfer log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transfer.Log.query(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer_log
  test "query! transfer log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Transfer.Log.query!(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer_log
  test "query! transfer log with filters" do
    user = StarkBankTest.Credentials.project()

    transfer = StarkBank.Transfer.query!(user, status: "success")
     |> Enum.take(1)
     |> hd()

    StarkBank.Transfer.Log.query!(user, limit: 1, transfer_ids: [transfer.id], types: "success")
     |> Enum.take(5)
     |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :transfer_log
  test "get transfer log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Transfer.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _log} = StarkBank.Transfer.Log.get(user, log.id)
  end

  @tag :transfer_log
  test "get! transfer log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Transfer.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    _log = StarkBank.Transfer.Log.get!(user, log.id)
  end
end
