defmodule StarkBankTest.BoletoPaymentLog do
  use ExUnit.Case

  @tag :boleto_payment_log
  test "query boleto payment log" do
    StarkBank.BoletoPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment_log
  test "query! boleto payment log" do
    StarkBank.BoletoPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :boleto_payment_log
  test "query! boleto payment log with filters" do
    payment =
      StarkBank.BoletoPayment.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.BoletoPayment.Log.query!(limit: 1, payment_ids: [payment.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :boleto_payment_log
  test "page boleto payment log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.BoletoPayment.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto_payment_log
  test "page! boleto payment log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.BoletoPayment.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :boleto_payment_log
  test "get boleto payment log" do
    log =
      StarkBank.BoletoPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.BoletoPayment.Log.get(log.id)
  end

  @tag :boleto_payment_log
  test "get! boleto payment log" do
    log =
      StarkBank.BoletoPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.BoletoPayment.Log.get!(log.id)
  end
end
