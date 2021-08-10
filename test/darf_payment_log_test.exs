defmodule StarkBankTest.DarfPaymentLog do
  use ExUnit.Case

  @tag :darf_payment_log
  test "query darf payment log" do
    StarkBank.DarfPayment.Log.query(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :darf_payment_log
  test "query! darf payment log" do
    StarkBank.DarfPayment.Log.query!(limit: 101)
    |> Enum.take(200)
    |> (fn list -> assert length(list) <= 101 end).()
  end

  @tag :darf_payment_log
  test "page darf payment log" do
    {:ok, ids} = StarkBankTest.Utils.Page.get(&StarkBank.DarfPayment.Log.page/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :darf_payment_log
  test "page! darf payment log" do
    ids = StarkBankTest.Utils.Page.get!(&StarkBank.DarfPayment.Log.page!/1, 2, limit: 5)
    assert length(ids) == 10
  end

  @tag :darf_payment_log
  test "get darf payment log" do
    log =
      StarkBank.DarfPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    {:ok, get_log} = StarkBank.DarfPayment.Log.get(log.id)
    assert log.id == get_log.id
  end

  @tag :darf_payment_log
  test "get! darf payment log" do
    log =
      StarkBank.DarfPayment.Log.query!()
      |> Enum.take(1)
      |> hd()

    get_log = StarkBank.DarfPayment.Log.get!(log.id)
    assert log.id == get_log.id
  end
end
