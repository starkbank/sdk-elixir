defmodule StarkBankTest.TaxPaymentLog do
  use ExUnit.Case

  @tag :tax_payment_log
  test "query tax payment log" do
    StarkBank.TaxPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :tax_payment_log
  test "query! tax payment log" do
    StarkBank.TaxPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :tax_payment_log
  test "page tax payment log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.TaxPayment.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :tax_payment_log
  test "page! tax payment log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.TaxPayment.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :tax_payment_log
  test "get tax payment log" do
    log =
      StarkBank.TaxPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.TaxPayment.Log.get(log.id)
    assert log.id == get_log.id
  end

  @tag :tax_payment_log
  test "get! tax payment log" do
    log =
      StarkBank.TaxPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.TaxPayment.Log.get!(log.id)
    assert log.id == get_log.id
  end
end
