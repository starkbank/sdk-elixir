defmodule StarkBankTest.BoletoHolmesLog do
  use ExUnit.Case

  @tag :boleto_holmes_log
  test "query boleto holmes log" do
    StarkBank.BoletoHolmes.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes_log
  test "query! boleto holmes log" do
    StarkBank.BoletoHolmes.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes_log
  test "query! boleto log with filters" do
    sherlock =
      StarkBank.BoletoHolmes.query!(status: "solved")
      |> Enum.take(1)
      |> hd()

    StarkBank.BoletoHolmes.Log.query!(limit: 1, holmes_ids: [sherlock.id], types: "solved")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :boleto_holmes_log
  test "get boleto holmes log" do
    log =
      StarkBank.BoletoHolmes.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.BoletoHolmes.Log.get(log.id)
  end

  @tag :boleto_holmes_log
  test "get! boleto holmes log" do
    log =
      StarkBank.BoletoHolmes.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.BoletoHolmes.Log.get!(log.id)
  end
end
