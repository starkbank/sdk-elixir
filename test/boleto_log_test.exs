defmodule StarkBankTest.BoletoLog do
  use ExUnit.Case

  @tag :boleto_log
  test "query boleto log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Boleto.Log.query(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_log
  test "query! boleto log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Boleto.Log.query!(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_log
  test "query! boleto log with filters" do
    user = StarkBankTest.Credentials.project()

    boleto = StarkBank.Boleto.query!(user, status: "paid")
     |> Enum.take(1)
     |> hd()

    StarkBank.Boleto.Log.query!(user, limit: 1, boleto_ids: [boleto.id], types: "paid")
     |> Enum.take(5)
     |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :boleto_log
  test "get boleto log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Boleto.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _log} = StarkBank.Boleto.Log.get(user, log.id)
  end

  @tag :boleto_log
  test "get! boleto log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Boleto.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    _log = StarkBank.Boleto.Log.get!(user, log.id)
  end
end
