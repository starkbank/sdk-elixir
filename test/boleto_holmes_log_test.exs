defmodule StarkBankTest.BoletoHolmesLog do
  use ExUnit.Case

  @tag :boleto_holmes_log
  test "query boleto holmes log" do
    StarkBank.BoletoHolmes.Log.query(query: [limit: 101])
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes_log
  test "query! boleto holmes log" do
    StarkBank.BoletoHolmes.Log.query!(query: [limit: 101])
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_holmes_log
  test "query! boleto log with filters" do
    sherlock =
      StarkBank.BoletoHolmes.query!(query: [status: "solved"])
      |> Enum.take(1)
      |> hd()

    StarkBank.BoletoHolmes.Log.query!(query: [limit: 1, types: "solved"], holmes_ids: [sherlock.id])
    |> (fn list -> assert Enum.count(list) == 1 end).()
  end

  @tag :boleto_holmes_log
  test "page boleto holmes log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.BoletoHolmes.Log.page/1, 2, query: [limit: 1])
    assert length(ids) == 2
  end

  @tag :boleto_holmes_log
  test "page! boleto holmes log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.BoletoHolmes.Log.page!/1, 2, query: [limit: 1])
    assert length(ids) == 2
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
