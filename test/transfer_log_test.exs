defmodule StarkBankTest.TransferLog do
  use ExUnit.Case

  @tag :transfer_log
  test "query transfer log" do
    StarkBank.Transfer.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer_log
  test "query! transfer log" do
    StarkBank.Transfer.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :transfer_log
  test "query! transfer log with filters" do
    transfer =
      StarkBank.Transfer.query!(status: "success")
      |> Enum.take(1)
      |> hd()

    StarkBank.Transfer.Log.query!(limit: 1, transfer_ids: [transfer.id], types: "success")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :transfer_log
  test "get transfer log" do
    log =
      StarkBank.Transfer.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.Transfer.Log.get(log.id)
  end

  @tag :transfer_log
  test "get! transfer log" do
    log =
      StarkBank.Transfer.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.Transfer.Log.get!(log.id)
  end
end
