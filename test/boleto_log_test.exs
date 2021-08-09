defmodule StarkBankTest.BoletoLog do
  use ExUnit.Case

  @tag :boleto_log
  test "query boleto log" do
    StarkBank.Boleto.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_log
  test "query! boleto log" do
    StarkBank.Boleto.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_log
  test "query! boleto log with filters" do
    boleto =
      StarkBank.Boleto.query!(status: "paid")
      |> Enum.take(1)
      |> hd()

    StarkBank.Boleto.Log.query!(limit: 1, boleto_ids: [boleto.id], types: "paid")
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :boleto_log
  test "page boleto log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.Boleto.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto_log
  test "page! boleto log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.Boleto.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto_log
  test "get boleto log" do
    log =
      StarkBank.Boleto.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.Boleto.Log.get(log.id)
  end

  @tag :boleto_log
  test "get! boleto log" do
    log =
      StarkBank.Boleto.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.Boleto.Log.get!(log.id)
  end
end
