defmodule StarkBankTest.BoletoPaymentLog do
  use ExUnit.Case

  @tag :boleto_payment_log
  test "query boleto payment log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Boleto.Log.query(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment_log
  test "query! boleto payment log" do
    user = StarkBankTest.Credentials.project()
    StarkBank.Payment.Boleto.Log.query!(user, limit: 101)
     |> Enum.take(200)
     |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment_log
  test "query! boleto payment log with filters" do
    user = StarkBankTest.Credentials.project()

    payment = StarkBank.Payment.Boleto.query!(user)
     |> Enum.take(1)
     |> hd()

    StarkBank.Payment.Boleto.Log.query!(user, limit: 1, payment_ids: [payment.id])
     |> Enum.take(5)
     |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :boleto_payment_log
  test "get boleto payment log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Payment.Boleto.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    {:ok, _log} = StarkBank.Payment.Boleto.Log.get(user, log.id)
  end

  @tag :boleto_payment_log
  test "get! boleto payment log" do
    user = StarkBankTest.Credentials.project()
    log = StarkBank.Payment.Boleto.Log.query!(user)
     |> Enum.take(1)
     |> hd()
    _log = StarkBank.Payment.Boleto.Log.get!(user, log.id)
  end
end
