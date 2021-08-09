defmodule StarkBankTest.BrcodePaymentLog do
  use ExUnit.Case

  @tag :brcode_payment_log
  test "query brcode payment log" do
    StarkBank.BrcodePayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :brcode_payment_log
  test "query! brcode payment log" do
    StarkBank.BrcodePayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :brcode_payment_log
  test "query! brcode payment log with filters" do
    payment =
      StarkBank.BrcodePayment.query!()
      |> Enum.take(1)
      |> hd()

    StarkBank.BrcodePayment.Log.query!(limit: 1, payment_ids: [payment.id])
    |> Enum.take(5)
    |> (fn list -> assert length(list) == 1 end).()
  end

  @tag :brcode_payment_log
  test "page brcode payment log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.BrcodePayment.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :brcode_payment_log
  test "page! brcode payment log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.BrcodePayment.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :brcode_payment_log
  test "get brcode payment log" do
    log =
      StarkBank.BrcodePayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, _log} = StarkBank.BrcodePayment.Log.get(log.id)
  end

  @tag :brcode_payment_log
  test "get! brcode payment log" do
    log =
      StarkBank.BrcodePayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    _log = StarkBank.BrcodePayment.Log.get!(log.id)
  end
end
